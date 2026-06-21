import 'dart:async';
import 'package:flutter/animation.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
import 'package:grimoji/features/match/board/utils/manager.dart';
import 'package:grimoji/features/match/board/utils/announcer.dart';
import 'package:grimoji/features/match/engines/game_engine.dart';
import 'package:grimoji/features/match/model/collected_emoji.dart';
import 'package:grimoji/features/match/utils/match_detector.dart';
import 'package:grimoji/features/match/state.dart';
import 'package:grimoji/features/match/utils/swipe_detector.dart';
import 'package:logging/logging.dart';

class GameCoordinator {
  final GameEngine engine;
  final GameState state;
  final BoardManager boardManager;
  final AudioController audio;
  final void Function(int) onTargetAcquired;
  final Future<bool> Function() onComboFinished;
  final Logger _log = Logger('GameCoordinator');

  Timer? _hintTimer;
  List<TileCoordinate>? _currentHints;

  GameCoordinator({
    required this.engine,
    required this.state,
    required this.boardManager,
    required this.audio,
    required this.onTargetAcquired,
    required this.onComboFinished,
  });

  void initialize() {
    engine.initialize();
    resetHintTimer();
  }

  void startInitialDrop() {
    boardManager.triggerInitialFall();
    state.updateUI();
    resetHintTimer();
  }

  Future<void> resolveTap(TileCoordinate coord) async {
    if (state.isGameOver || state.isPaused) return;

    final tile = engine.grid[coord.row][coord.col];
    final actions = engine.processTappedBehavior(tile, coord.row, coord.col);

    if (actions.isEmpty) return;

    state.setProcessing(true);
    resetHintTimer();

    audio.playSfx(SfxType.swipe);

    engine.executeBehaviorActions(actions, coord.row, coord.col);
    state.updateUI();

    await Future.delayed(const Duration(milliseconds: 700));
    if (state.isDisposed) return;

    await executeEmojiBehaviors();
    if (state.isDisposed) return;

    await _cascadeSequence(coord);
  }

  Future<void> resolveSwipe(
    TileCoordinate dCoord,
    TileCoordinate tCoord,
  ) async {
    final dtile = engine.grid[dCoord.row][dCoord.col];
    final ttile = engine.grid[tCoord.row][tCoord.col];

    _log.info(
      " swipe ${dtile.emoji.visual} -> ${ttile.emoji.visual} registered",
    );
    if (state.isGameOver || state.isPaused) return;

    state.setProcessing(true);
    resetHintTimer();

    final decision = engine.evaluateSwipe(dCoord, tCoord);

    if (decision.type == SwipeResult.invalid) {
      audio.playSfx(SfxType.invalidMove);
      boardManager.swapTiles(dCoord, tCoord);
      state.updateUI();

      await Future.delayed(swapAnimationTime);
      if (state.isDisposed) return;

      boardManager.swapTiles(tCoord, dCoord);
      state.updateUI();

      state.setHasTargetCombo(false);
      state.setProcessing(false);
      resetHintTimer();
      return;
    }

    audio.playSfx(SfxType.swipe);

    state.updateUI();
    await Future.delayed(const Duration(milliseconds: 100));
    if (state.isDisposed) return;

    if (decision.type == SwipeResult.specialBehavior) {
      final dTile = engine.grid[dCoord.row][dCoord.col];
      final TileCoordinate triggerCoord = dTile.behavior != null
          ? dCoord
          : tCoord;

      engine.executeBehaviorActions(
        decision.actions,
        triggerCoord.row,
        triggerCoord.col,
      );
      state.updateUI();

      await Future.delayed(const Duration(milliseconds: 700));
      if (state.isDisposed) return;

      await executeEmojiBehaviors();
      if (state.isDisposed) return;

      await _cascadeSequence(tCoord);
      return;
    }

    await _cascadeSequence(tCoord);
  }

  Future<void> _cascadeSequence(TileCoordinate focusCoordinate) async {
    state.announcer.clear();
    state.setComboMultiplier(0);
    state.resetTilesCleared();

    final Set<TurnEvent> events = {};

    while (true) {
      bool cascadeOccurred = await executeCascadePhase(focusCoordinate);
      if (state.isDisposed) return;

      if (cascadeOccurred) {
        events.add(TurnEvent.merge);
      }
      if (state.hasLegendaryEmoji) {
        events.add(TurnEvent.legendaryEmoji);
        state.setLegendaryEmoji(false);
      }

      bool detonationOccurred = await executeDetonatorPhase();
      if (state.isDisposed) return;

      if (detonationOccurred) {
        events.add(TurnEvent.explosion);
      }

      if (!cascadeOccurred && !detonationOccurred) {
        break;
      }
    }

    state.announcer.evaluateTurn(
      events: events,
      combo: state.currentComboMultiplier,
      tilesCleared: state.tilesCleared,
    );

    if (state.announcer.isSpeaking) {
      state.announcer.startCooldown();
    }

    await _finalizeTurnLifecycle();
  }

  Future<bool> executeCascadePhase(TileCoordinate targetCoordinate) async {
    bool isFirstMatch = true;
    bool executionOccurred = false;
    Set<int> affectedColumns = {};
    Set<int> affectedRows = {};
    bool hadLegendaryEmo = false;

    while (true) {
      await waitIfPaused();
      if (state.isDisposed) return false;

      final matchedGroups = (affectedColumns.isEmpty || affectedRows.isEmpty)
          ? MatchDetector.findMatchedGroups(boardManager.gridTiles)
          : MatchDetector.findMatchesInVectors(
              grid: boardManager.gridTiles,
              affectedColumns: affectedColumns,
              affectedRows: affectedRows,
            );

      matchedGroups.removeWhere(
        (group) => group.coordinates.any((c) {
          final tile = engine.grid[c.row][c.col];
          return tile.isTriggered || tile.isExploding || tile.isMerging;
        }),
      );

      if (matchedGroups.isEmpty) break;

      executionOccurred = true;

      if (!isFirstMatch) {
        state.incrementComboMultiplier();
      }

      engine.categorizeAnimations(
        matchedGroups,
        isFirstMatch,
        targetCoordinate,
      );
      state.updateUI();

      await Future.delayed(clearAnimationTime);
      if (state.isDisposed) return false;

      final stepResult = engine.processCascadeStep(
        matchedGroups: matchedGroups,
        targetCoordinate: targetCoordinate,
        isFirstMatch: isFirstMatch,
      );

      resolveCollectedEmojis(stepResult.collectedEmojis);
      boardManager.flagFlyingTargetEmojis(stepResult.tilesToDestroy);

      Set<TileCoordinate> mergedFlyingTargets = {};
      for (int r = 0; r < BoardManager.rows; r++) {
        for (int c = 0; c < BoardManager.cols; c++) {
          final tile = engine.grid[r][c];
          if (tile.isFlying &&
              !stepResult.tilesToDestroy.any(
                (cd) => cd.row == r && cd.col == c,
              )) {
            mergedFlyingTargets.add(TileCoordinate(row: r, col: c));
          }
        }
      }
      state.updateUI();

      int tilesCleared =
          stepResult.tilesToDestroy.length + mergedFlyingTargets.length;
      state.addTilesCleared(tilesCleared);

      for (var coord in stepResult.transformed) {
        final tile = engine.grid[coord.row][coord.col];
        if (RecipeBook.isLegendary(tile.emoji)) {
          hadLegendaryEmo = true;
        }
      }

      final Set<TileCoordinate> matches = matchedGroups
          .expand((g) => g.coordinates)
          .toSet();

      bool hasAoE = stepResult.tilesToDestroy.any(
        (coord) =>
            !matches.any((c) => c.row == coord.row && c.col == coord.col),
      );
      bool hasTransmutations = engine.grid.any(
        (row) => row.any((t) => t.isTransmuting),
      );

      if (hasAoE || hasTransmutations) {
        await Future.delayed(clearAnimationTime);
        boardManager.clearTransmutingFlags();
      } else {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final Set<TileCoordinate> allDestroyed = {
        ...stepResult.tilesToDestroy,
        ...mergedFlyingTargets,
      };

      final gravityDeltas = boardManager.applyGravity(allDestroyed);
      engine.initializeBehaviors();
      affectedColumns = gravityDeltas.cols;
      affectedRows = gravityDeltas.rows;

      boardManager.clearAllFlyingFlags();
      state.updateUI();

      await Future.delayed(const Duration(milliseconds: 50));
      if (state.isDisposed) return false;

      boardManager.triggerInitialFall();
      state.updateUI();

      await Future.delayed(gravityAnimationTime);
      if (state.isDisposed) return false;

      isFirstMatch = false;
    }

    if (hadLegendaryEmo) {
      state.setLegendaryEmoji(true);
    }

    return executionOccurred;
  }

  Future<bool> executeDetonatorPhase() async {
    bool executionOccurred = false;

    while (true) {
      List<Tile> primedBombs = boardManager.getTriggeredEmojis();
      if (primedBombs.isEmpty) break;

      executionOccurred = true;
      await waitIfPaused();
      if (state.isDisposed) return false;

      final stepResult = engine.processDetonationStep();
      resolveCollectedEmojis(stepResult.collectedEmojis);
      state.updateUI();

      Set<TileCoordinate> behaviorDestroyed = {};
      for (int r = 0; r < BoardManager.rows; r++) {
        for (int c = 0; c < BoardManager.cols; c++) {
          final tile = engine.grid[r][c];
          if (tile.isTaggedForDestruct) {
            behaviorDestroyed.add(TileCoordinate(row: r, col: c));
            tile.isTaggedForDestruct = false;
          }
        }
      }

      boardManager.flagFlyingTargetEmojis(stepResult.destroyed);
      state.updateUI();

      await Future.delayed(clearAnimationTime);
      if (state.isDisposed) return false;

      Set<TileCoordinate> targetFlyingTransforms = {};
      for (var coord in stepResult.transformed) {
        final tile = engine.grid[coord.row][coord.col];
        resolveCollectedEmojis([CollectedEmoji(emoji: tile.emoji, count: 1)]);
        if (tile.emoji == engine.level.targetEmoji) {
          tile.isFlying = true;
          targetFlyingTransforms.add(coord);
        }
      }

      final Set<TileCoordinate> allDestroyed = {
        ...stepResult.destroyed,
        ...targetFlyingTransforms,
        ...behaviorDestroyed,
      };

      if (behaviorDestroyed.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 700));
      }

      boardManager.applyGravity(allDestroyed);
      engine.initializeBehaviors();
      boardManager.clearAllFlyingFlags();
      state.updateUI();

      await Future.delayed(const Duration(milliseconds: 50));
      if (state.isDisposed) return false;

      boardManager.triggerInitialFall();
      state.updateUI();

      await Future.delayed(gravityAnimationTime);
      if (state.isDisposed) return false;
    }

    return executionOccurred;
  }

  Future<bool> executeEmojiBehaviors() async {
    Set<TileCoordinate> destroyedByBehavior = {};

    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        final tile = engine.grid[r][c];
        if (tile.isTaggedForDestruct || tile.isDestructTrigger) {
          destroyedByBehavior.add(TileCoordinate(row: r, col: c));
          engine.grid[r][c].isTaggedForDestruct = false;
          engine.grid[r][c].isDestructTrigger = false;
        }
      }
    }

    if (destroyedByBehavior.isEmpty) {
      return false;
    }

    state.announcer.evaluateTurn(
      events: {TurnEvent.blackHole},
      combo: state.currentComboMultiplier,
      tilesCleared: destroyedByBehavior.length,
    );

    boardManager.applyGravity(destroyedByBehavior);
    engine.initializeBehaviors();
    state.updateUI();

    await Future.delayed(const Duration(milliseconds: 50));
    if (state.isDisposed) return false;

    boardManager.triggerInitialFall();
    state.updateUI();

    await Future.delayed(gravityAnimationTime);
    if (state.isDisposed) return false;

    return true;
  }

  Future<void> _finalizeTurnLifecycle() async {
    if (!engine.hasPossibleMoves() && !state.isGameOver && !state.isFeverTime) {
      await shuffleBoard();
    }

    _log.info('Processing After Turn Emoji Behaviors...');
    engine.processTurnEndBehaviors();
    state.updateUI();

    await Future.delayed(const Duration(milliseconds: 300));
    if (state.isDisposed) return;

    state.setHasTargetCombo(false);
    state.setProcessing(false);

    if (!state.isDisposed) {
      state.updateUI();
      resetHintTimer();
      await onComboFinished();
    }
  }

  void resolveCollectedEmojis(List<CollectedEmoji> collections) {
    for (var collection in collections) {
      if (collection.emoji == engine.level.targetEmoji) {
        state.setHasTargetCombo(true);
        onTargetAcquired(collection.count);
      }
    }
    state.updateUI();
  }

  Future<void> shuffleBoard() async {
    state.setShuffleProgress(0.0);
    state.setShuffling(true);

    await Future.delayed(const Duration(milliseconds: 600));
    if (state.isDisposed) return;

    engine.shuffleGrid();

    state.setShuffleProgress(1.0);
    state.updateUI();

    await Future.delayed(const Duration(milliseconds: 600));
    if (state.isDisposed) return;

    state.setShuffling(false);

    if (!state.isFeverTime) {
      resetHintTimer();
    }
  }

  void resetHintTimer() {
    if (state.isDisposed || state.isGameOver || state.isFeverTime) {
      _hintTimer?.cancel();
      return;
    }

    clearHint();
    if (!state.isProcessing && !state.isShuffling) {
      _hintTimer?.cancel();
      _hintTimer = Timer(const Duration(seconds: 5), _triggerHint);
    }
  }

  Future<void> _triggerHint() async {
    if (state.isProcessing ||
        state.isShuffling ||
        state.isDisposed ||
        state.isGameOver ||
        state.isPaused ||
        state.isFeverTime) {
      return;
    }

    _currentHints = await engine.getHintMove();

    if (state.isDisposed) return;

    if (_currentHints != null) {
      audio.playSfx(SfxType.hint);
      Tile tileA = engine.grid[_currentHints![0].row][_currentHints![0].col];
      Tile tileB = engine.grid[_currentHints![1].row][_currentHints![1].col];

      tileA.isHinting = true;
      tileA.hintPartner = tileB.coordinate;
      tileB.isHinting = true;
      tileB.hintPartner = tileA.coordinate;

      state.updateUI();
    } else {
      shuffleBoard();
    }
  }

  void clearHint() {
    _hintTimer?.cancel();
    _currentHints = null;

    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        engine.grid[r][c].isHinting = false;
        engine.grid[r][c].hintPartner = null;
      }
    }
    state.updateUI();
  }

  Future<void> waitIfPaused() async {
    while (state.isPaused && !state.isDisposed) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void togglePause() {
    state.setPaused(!state.isPaused);
  }

  Future<void> executeFeverSequence(
    int bonusBombs,
    VoidCallback onSpawn,
  ) async {
    state.setFeverTime(true);
    state.setFeverBombCount(bonusBombs);
    state.setReFeverBombs(bonusBombs);
    state.setFeverTimer(bonusBombs);
    cancelHintTimer();

    while (state.isProcessing && !state.isDisposed) {
      await Future.delayed(const Duration(milliseconds: 250));
    }
    if (state.isDisposed) return;

    if (bonusBombs > 0) {
      for (int i = 0; i < bonusBombs; i++) {
        if (state.isDisposed) return;

        boardManager.spawnBomb();
        onSpawn();
        state.updateUI();

        await Future.delayed(const Duration(milliseconds: 200));
      }

      await Future.delayed(const Duration(milliseconds: 300));
      while (boardManager.countSafeBombs() > 0) {
        if (state.isDisposed) return;

        final primedBombs = boardManager.getTriggeredEmojis();
        final focusCoord = primedBombs.isNotEmpty
            ? primedBombs.first.coordinate
            : TileCoordinate(row: 3, col: 3);

        boardManager.triggerNextBomb();
        state.updateUI();

        await Future.delayed(const Duration(milliseconds: 300));

        await _cascadeSequence(focusCoord);

        while (state.isProcessing && !state.isDisposed) {
          await Future.delayed(const Duration(milliseconds: 250));
        }
        if (state.isDisposed) return;

        state.setReFeverBombs(boardManager.countSafeBombs());
        state.decrementFeverTimer();
        state.updateUI();

        await Future.delayed(const Duration(milliseconds: 150));
      }
    }

    state.setFeverComplete(true);
    state.setGameOver();

    while ((state.isProcessing ||
            state.announcer.isSpeaking ||
            state.isShuffling) &&
        !state.isDisposed) {
      await Future.delayed(const Duration(milliseconds: 250));
    }
    if (state.isDisposed) return;

    await Future.delayed(const Duration(milliseconds: 500));

    if (!state.isDisposed) {
      clearHint();
    }
  }

  void skipFever() {
    state.setGameOver();
    state.setFeverTime(false);
    state.setFeverBombCount(0);
    state.setReFeverBombs(0);
    state.setFeverTimer(0);
  }

  void cancelHintTimer() {
    _hintTimer?.cancel();
  }

  void dispose() {
    cancelHintTimer();
    state.dispose();
  }
}
