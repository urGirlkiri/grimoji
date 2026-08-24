import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/reactions/models/reaction.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/index.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:logging/logging.dart';

class TrailerDriver {
  static final _log = Logger('TrailerDriver');
  final LevelState levelState;
  final BuildContext context;
  bool _disposed = false;
  bool _started = false;

  bool _usedHourglass = false;
  bool _usedGlove = false;
  bool _usedBlood = false;
  bool _usedCrystalBall = false;

  static const _introPause = Duration(milliseconds: 1500);
  static const _hintDwell = Duration(milliseconds: 1000);
  static const _visualSettle = Duration(milliseconds: 500);
  static const _preSwapDwell = Duration(milliseconds: 1200);
  static const _selectionDwell = Duration(seconds: 1);
  static const _postSettlePause = Duration(milliseconds: 1200);
  static const _powerupReadPause = Duration(milliseconds: 800);
  static const _prelevelDwell = Duration(milliseconds: 800);

  TrailerDriver({required this.levelState, required this.context});

  void dispose() => _disposed = true;

  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;

    try {
      await _run();
    } catch (e, st) {
      _log.severe('TrailerDriver crashed: $e', e, st);
    }
  }

  Future<void> _run() async {
    await _waitForBoardReady();
    if (_disposed) return;

    await _delay(_introPause);
    if (_disposed) return;

    await _showcasePrelevelBoosters();
    if (_disposed) return;

    int swapCount = 0;
    int loopCount = 0;
    while (!_disposed &&
        !levelState.goalManager.isComplete &&
        !levelState.gameState.isGameOver) {
      final remaining = levelState.secondsRemaining;

      if (!_usedGlove && swapCount >= 2) {
        await _usePowerup('boxing_glove');
        _usedGlove = true;
        if (_disposed) return;
      }

      if (!_usedBlood && swapCount >= 4) {
        await _usePowerup('blood');
        _usedBlood = true;
        if (_disposed) return;
      }

      if (!_usedHourglass && remaining <= 30) {
        await _usePowerup('hourglass');
        _usedHourglass = true;
        if (_disposed) return;
      }

      if (!_usedCrystalBall && remaining <= 15) {
        await _useCrystalBallHint();
        _usedCrystalBall = true;
        if (_disposed) return;
      }

      await _performSwap();
      if (_disposed) return;
      swapCount++;

      if (++loopCount > 200) {
        _log.warning('Trailer loop exceeded safety limit; stopping driver');
        break;
      }
    }
  }

  Future<void> _waitForBoardReady() async {
    while (!_disposed &&
        (levelState.gameState.isProcessing ||
            levelState.gameState.isShuffling)) {
      await _delay(const Duration(milliseconds: 100));
    }
  }

  Future<void> _waitUntilIdle() async {
    while (!_disposed &&
        (levelState.gameState.isProcessing ||
            levelState.gameState.isShuffling ||
            levelState.gameState.isPaused)) {
      await _delay(const Duration(milliseconds: 100));
    }
  }

  Future<void> _delay(Duration duration) => Future.delayed(duration);

  Future<void> _showcasePrelevelBoosters() async {
    final specials = [
      Emojis.bomb,
      Emojis.barberPole,
      Emojis.hole,
      Emojis.wheel,
      Emojis.ghost,
    ];

    for (final emoji in specials) {
      if (_disposed) return;
      if (await _tryTapSpecial(emoji)) {
        await _waitUntilIdle();
        await _delay(_prelevelDwell);
      }
    }
  }

  Future<bool> _tryTapSpecial(GameEmoji emoji) async {
    final coord = _findTile(emoji);
    if (coord == null) return false;

    final tile = levelState.engine.grid[coord.row][coord.col];
    final reaction = RecipeBook.getReactionFor(tile.emoji);
    final isExplosive =
        reaction != null && reaction.type == ReactionType.explosive;
    final actions = levelState.engine.processTappedBehavior(
      tile,
      coord.row,
      coord.col,
    );
    if (!isExplosive && actions.isEmpty) return false;
    if (tile.isTriggered) return false;

    await _waitUntilIdle();
    if (_disposed) return false;
    await _delay(_visualSettle);
    await levelState.coordinator.resolveTap(coord);
    return true;
  }

  TileCoordinate? _findTile(GameEmoji emoji) {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        if (levelState.engine.grid[r][c].emoji == emoji) {
          return TileCoordinate(row: r, col: c);
        }
      }
    }
    return null;
  }

  Future<void> _performSwap() async {
    await _waitUntilIdle();
    var hint = await levelState.engine.getHintMove();
    if (_disposed) return;

    if (hint == null) {
      _log.info('No hint available; shuffling board');
      await levelState.coordinator.shuffleBoard();
      await _waitUntilIdle();
      if (_disposed) return;
      hint = await levelState.engine.getHintMove();
      if (_disposed) return;
    }

    if (hint != null && hint.length >= 2) {
      await _delay(_visualSettle);
      _highlightHint(hint[0], hint[1]);
      await _delay(_preSwapDwell);
      await _waitUntilIdle();
      if (_disposed) return;
      await levelState.coordinator.resolveSwipe(hint[0], hint[1]);
      await _waitUntilIdle();
      await _delay(_postSettlePause);
    }
  }

  Future<void> _useCrystalBallHint() async {
    _log.info('Enabling crystal ball hint for low time');
    levelState.gameState.setHintsEnabled(true);
    levelState.coordinator.resetHintTimer();

    TileCoordinate? a;
    TileCoordinate? b;
    var waited = 0;
    while (waited < 40 && !_disposed) {
      (a, b) = _findHintingPair();
      if (a != null && b != null) break;
      await _delay(const Duration(milliseconds: 100));
      waited++;
    }
    if (_disposed || a == null || b == null) return;

    await _delay(_hintDwell);
    await _waitUntilIdle();
    if (_disposed) return;

    await levelState.coordinator.resolveSwipe(a, b);
    await _waitUntilIdle();
    await _delay(_postSettlePause);
  }

  void _highlightHint(TileCoordinate a, TileCoordinate b) {
    final tileA = levelState.engine.grid[a.row][a.col];
    final tileB = levelState.engine.grid[b.row][b.col];
    tileA
      ..isHinting = true
      ..hintPartner = b;
    tileB
      ..isHinting = true
      ..hintPartner = a;
    levelState.gameState.updateUI();
  }

  (TileCoordinate?, TileCoordinate?) _findHintingPair() {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        final tile = levelState.engine.grid[r][c];
        if (tile.isHinting && tile.hintPartner != null) {
          return (TileCoordinate(row: r, col: c), tile.hintPartner!);
        }
      }
    }
    return (null, null);
  }

  Future<void> _usePowerup(String id) async {
    final powerup = Powerup.byId(id);
    if (powerup == null) return;

    final handler = PowerupHandlerRegistry.get(id);
    if (handler == null) return;

    levelState.bumpPowerupIcon(id);
    await _delay(_powerupReadPause);

    if (id == 'hourglass') {
      if (_disposed || !context.mounted) return;
      await handler.execute(context, powerup, levelState);
      await _waitUntilIdle();
      await _delay(_postSettlePause);
      return;
    }

    final target = _pickPowerupTarget(id);
    if (target == null) return;

    if (!context.mounted) return;
    final future = handler.execute(context, powerup, levelState);
    var waited = 0;
    while (!_disposed && !levelState.isPowerupSelecting) {
      await _delay(const Duration(milliseconds: 20));
      if (++waited > 250) {
        _log.warning('Powerup $id never entered selection mode; aborting');
        return;
      }
    }
    if (_disposed || !context.mounted) return;

    await _delay(_selectionDwell);
    if (_disposed) return;

    levelState.onPowerTileTapped(target);
    try {
      await future.timeout(const Duration(seconds: 6));
    } catch (e) {
      _log.warning('Powerup $id did not complete in time: $e');
      levelState.completePowerupAnimation();
    }
    await _waitUntilIdle();
    await _delay(_postSettlePause);
  }

  TileCoordinate? _pickPowerupTarget(String id) {
    if (id == 'boxing_glove') return _pickPunchTarget();
    if (id == 'blood') return _pickBloodTarget();
    return null;
  }

  TileCoordinate? _pickPunchTarget() {
    for (int r = 2; r < BoardManager.rows - 1; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        final above = levelState.engine.grid[r - 1][c].emoji;
        final above2 = levelState.engine.grid[r - 2][c].emoji;
        final below = levelState.engine.grid[r + 1][c].emoji;
        if (above == above2 &&
            above != levelState.level.targetEmoji &&
            below == above &&
            levelState.engine.grid[r][c].emoji !=
                levelState.level.targetEmoji) {
          return TileCoordinate(row: r, col: c);
        }
      }
    }

    final random = Random();
    for (var i = 0; i < 10; i++) {
      final r = random.nextInt(BoardManager.rows - 1) + 1;
      final c = random.nextInt(BoardManager.cols);
      if (levelState.engine.grid[r][c].emoji != levelState.level.targetEmoji) {
        return TileCoordinate(row: r, col: c);
      }
    }
    return null;
  }

  TileCoordinate? _pickBloodTarget() {
    int bestScore = -1;
    TileCoordinate? best;
    for (int r = 1; r < BoardManager.rows - 1; r++) {
      for (int c = 1; c < BoardManager.cols - 1; c++) {
        int score = 0;
        for (int i = 0; i < BoardManager.rows; i++) {
          if (levelState.engine.grid[i][c].emoji ==
              levelState.level.targetEmoji) {
            score++;
          }
        }
        for (int j = 0; j < BoardManager.cols; j++) {
          if (levelState.engine.grid[r][j].emoji ==
              levelState.level.targetEmoji) {
            score++;
          }
        }
        if (score > bestScore) {
          bestScore = score;
          best = TileCoordinate(row: r, col: c);
        }
      }
    }
    return best;
  }
}
