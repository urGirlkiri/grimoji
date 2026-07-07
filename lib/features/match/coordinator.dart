import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
import 'package:grimoji/features/match/utils/manager.dart';
import 'package:grimoji/features/match/announcer.dart';
import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/model/collected_emoji.dart';
import 'package:grimoji/features/match/detectors/match.dart';
import 'package:grimoji/features/match/state.dart';
import 'package:grimoji/features/match/detectors/swipe.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/board/effects/ghost_dive/effect.dart';
import 'package:grimoji/features/match/board/effects/wheel_roll/effect.dart';
import 'package:grimoji/features/match/utils/evaluator.dart';
import 'package:logging/logging.dart';

class GameCoordinator {
  final GameEngine engine;
  final GameState state;
  final BoardManager boardManager;
  final AudioController audio;
  final void Function(int) onTargetAcquired;
  final Future<bool> Function() onComboFinished;
  void Function(int row, int col, bool isHorizontal)? onLineClear;
  Future<void> Function(RollEffect)? onWheelRoll;
  Future<void> Function(GhostDiveEffect)? onGhostDive;
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

    final reaction = RecipeBook.getReactionFor(tile.emoji);
    final isExplosive =
        reaction != null && reaction.type == ReactionType.explosive;

    if (isExplosive && !tile.isTriggered) {
      state.setProcessing(true);
      resetHintTimer();
      audio.playSfx(SfxType.trigger);
      tile.isTriggered = true;
      state.updateUI();
      await _cascadeSequence(coord);
      return;
    }

    final actions = engine.processTappedBehavior(tile, coord.row, coord.col);

    if (actions.isEmpty) return;

    state.setProcessing(true);
    resetHintTimer();

    audio.playSfx(SfxType.swipe);

    engine.executeBehaviorActions(actions, coord.row, coord.col);
    state.updateUI();

    if (_anySwallowPending()) {
      await Future.delayed(swallowAnimationLock);
      if (state.isDisposed) return;
    }

    if (_anyWheelPending()) {
      await _executeWheelPhase(
        isHorizontal: true,
        isWrapping: true,
        triggerCoord: coord,
      );
      if (state.isDisposed) return;
    }

    if (_anyGhostPending()) {
      await _executeGhostPhase();
      if (state.isDisposed) return;
    }

    await _executeEmojiBehaviors();
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

      await Future.delayed(swapSpeed);
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
    await Future.delayed(postSwipeScanDelay);
    if (state.isDisposed) return;

    if (decision.type == SwipeResult.specialBehavior) {
      final TileCoordinate triggerCoord = dtile.behavior != null
          ? tCoord
          : dCoord;

      final bool isHorizontal = dCoord.row == tCoord.row;
      final bool isPositive = isHorizontal
          ? tCoord.col > dCoord.col
          : tCoord.row > dCoord.row;

      engine.executeBehaviorActions(
        decision.actions,
        triggerCoord.row,
        triggerCoord.col,
      );
      state.updateUI();

      final hasSwallow = _anySwallowPending();
      if (hasSwallow) {
        await Future.delayed(swallowAnimationLock);
        if (state.isDisposed) return;
      }

      if (_anyWheelPending()) {
        await _executeWheelPhase(
          isHorizontal: isHorizontal,
          isWrapping: isPositive,
          triggerCoord: triggerCoord,
        );
        if (state.isDisposed) return;
      }

      await _executeEmojiBehaviors();
      if (state.isDisposed) return;

      await _cascadeSequence(tCoord);
      return;
    }

    await _cascadeSequence(tCoord);
  }

  Future<void> shuffleBoard() async {
    state.setShuffleProgress(0.0);
    state.setShuffling(true);

    await Future.delayed(shuffleWipeHalfTime);
    if (state.isDisposed) return;

    engine.shuffleGrid();

    state.setShuffleProgress(1.0);
    state.updateUI();

    await Future.delayed(shuffleWipeHalfTime);
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
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(seconds: 2), _triggerHint);
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

  void cancelHintTimer() {
    _hintTimer?.cancel();
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
    clearHint();

    while (state.isProcessing && !state.isDisposed) {
      await Future.delayed(flagPollingInterval);
    }
    if (state.isDisposed) return;

    if (bonusBombs > 0) {
      for (int i = 0; i < bonusBombs; i++) {
        if (state.isDisposed) return;

        boardManager.spawnBomb();
        onSpawn();
        state.updateUI();

        await Future.delayed(feverBombSpawnInterval);
      }

      await Future.delayed(feverDetonationChainDelay);
      for (int i = 0; i < bonusBombs; i++) {
        if (state.isDisposed) return;
        if (boardManager.countSafeBombs() == 0) break;

        final primedBombs = boardManager.getTriggeredEmojis();
        final focusCoord = primedBombs.isNotEmpty
            ? primedBombs.first.coordinate
            : TileCoordinate(row: 3, col: 3);

        boardManager.triggerNextBomb();
        state.updateUI();

        await Future.delayed(feverDetonationChainDelay);

        await _cascadeSequence(focusCoord);

        while (state.isProcessing && !state.isDisposed) {
          await Future.delayed(flagPollingInterval);
        }
        if (state.isDisposed) return;

        state.setReFeverBombs(boardManager.countSafeBombs());
        state.decrementFeverTimer();
        state.updateUI();

        await Future.delayed(feverClockTickInterval);
      }
    }

    state.setFeverComplete(true);
    state.setGameOver();

    while ((state.isProcessing ||
            state.announcer.isSpeaking ||
            state.isShuffling) &&
        !state.isDisposed) {
      await Future.delayed(flagPollingInterval);
    }
    if (state.isDisposed) return;

    await Future.delayed(postFeverResultsDelay);

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
    clearHint();
  }

  void dispose() {
    cancelHintTimer();
    state.dispose();
  }

  void _clearWheelTriggers() {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        engine.grid[r][c].isWheelTrigger = false;
      }
    }
  }

  bool _anyGhostPending() {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        final tile = engine.grid[r][c];
        if (tile.isGhostTrigger || tile.isGhostOrigin) return true;
      }
    }
    return false;
  }

  Future<void> _executeGhostPhase() async {
    final List<
      ({TileCoordinate origin, bool isBomb, TileCoordinate? bombOrigin})
    >
    triggers = [];
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        final tile = engine.grid[r][c];
        if (tile.isGhostTrigger || tile.isGhostOrigin) {
          TileCoordinate? bombOrigin;
          if (tile.isGhostOrigin) {
            final adjacents = boardManager.getAdjacentTiles(r, c);
            for (var adj in adjacents) {
              if (adj.emoji == Emojis.bomb) {
                bombOrigin = adj.coordinate;
                adj.isGhostBomb = true;
                break;
              }
            }
          }

          triggers.add((
            origin: TileCoordinate(row: r, col: c),
            isBomb: tile.isGhostOrigin,
            bombOrigin: bombOrigin,
          ));

          tile.isGhostTrigger = false;
          tile.isGhostOrigin = false;
          tile.clearBehavior();
        }
      }
    }
    if (triggers.isEmpty) return;

    final Set<TileCoordinate> destroyed = {};
    final Set<TileCoordinate> newBombs = {};

    for (final trigger in triggers) {
      final origin = trigger.origin;
      final target = await BoardEvaluator.findTarget(
        grid: engine.grid,
        targetEmoji: engine.level.targetEmoji,
      );
      if (state.isDisposed) return;
      if (target == null) continue;

      engine.grid[origin.row][origin.col].isGhostOrigin = true;
      if (kDebugMode) {
        engine.grid[target.row][target.col].isGhostTarget = true;
      }
      state.updateUI();

      final effect = GhostDiveEffect(
        origin: origin,
        target: target,
        bombOrigin: trigger.bombOrigin,
        isBomb: trigger.isBomb,
      );

      final diveAnimation = onGhostDive?.call(effect);

      if (!trigger.isBomb) {
        await Future.delayed(ghostDiveDuration);
        if (state.isDisposed) return;
      }

      await diveAnimation;
      if (state.isDisposed) return;

      if (kDebugMode) {
        engine.grid[target.row][target.col].isGhostTarget = false;
      }

      if (trigger.isBomb && trigger.bombOrigin != null) {
        engine
                .grid[trigger.bombOrigin!.row][trigger.bombOrigin!.col]
                .isGhostBomb =
            false;
        destroyed.add(trigger.bombOrigin!);
      }

      destroyed.add(origin);

      if (trigger.isBomb) {
        final targetTile = engine.grid[target.row][target.col];
        if (targetTile.emoji == engine.level.targetEmoji) {
          _resolveCollectedEmojis([
            CollectedEmoji(emoji: targetTile.emoji, count: 1),
          ]);
        }
        newBombs.add(target);
      } else {
        destroyed.add(target);
      }
    }

    if (destroyed.isNotEmpty) {
      boardManager.flagFlyingTargetEmojis(destroyed);
    }

    for (final coord in newBombs) {
      final tile = engine.grid[coord.row][coord.col];
      tile.isTriggered = true;
      tile.clearBehavior();
    }

    state.updateUI();

    if (destroyed.isNotEmpty) {
      await _settleBoard(destroyed);
    } else {
      await Future.delayed(preShatterDelay);
    }
  }

  bool _anyWheelPending() {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        if (engine.grid[r][c].isWheelTrigger) return true;
      }
    }
    return false;
  }

  Future<void> _executeWheelPhase({
    required bool isHorizontal,
    required bool isWrapping,
    required TileCoordinate triggerCoord,
  }) async {
    const int stepCount = 3;
    const stepDelay = wheelBombDropInterval;
    const tailDelay = wheelPostDropPause;

    const int rows = BoardManager.rows;
    const int cols = BoardManager.cols;

    final List<({TileCoordinate origin, List<TileCoordinate> steps})> wheels =
        [];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (engine.grid[r][c].isWheelTrigger) {
          engine.grid[r][c].isWheelTrigger = false;
          final origin = TileCoordinate(row: r, col: c);

          final List<TileCoordinate> steps = [];
          for (int i = 1; i <= stepCount; i++) {
            int sr = r;
            int sc = c;
            if (isHorizontal) {
              sc = ((sc + (isWrapping ? i : -i)) % cols + cols) % cols;
            } else {
              sr = ((sr + (isWrapping ? i : -i)) % rows + rows) % rows;
            }
            steps.add(TileCoordinate(row: sr, col: sc));
          }
          _log.info(
            'WheelPhase: found trigger at (${origin.row},${origin.col}) '
            'isHorizontal=$isHorizontal isWrapping=$isWrapping '
            'steps=${steps.map((s) => "(${s.row},${s.col})").join(",")}',
          );
          wheels.add((origin: origin, steps: steps));
        }
      }
    }
    _log.info('WheelPhase: total wheels found = ${wheels.length}');
    if (wheels.isEmpty) return;

    for (final w in wheels) {
      _log.info('WheelPhase: hiding origin (${w.origin.row},${w.origin.col})');
      engine.grid[w.origin.row][w.origin.col].isWheelOrigin = true;
      engine.grid[w.origin.row][w.origin.col].clearBehavior();
    }
    state.updateUI();

    await Future.delayed(wheelWindUpDuration);
    if (state.isDisposed) return;

    for (final w in wheels) {
      final effect = RollEffect(
        startRow: w.origin.row,
        startCol: w.origin.col,
        isHorizontal: isHorizontal,
        isWrapping: isWrapping,
        steps: w.steps,
      );
      _log.info(
        'WheelPhase: firing overlay id=${effect.id} '
        'start=(${effect.startRow},${effect.startCol})',
      );
      onWheelRoll?.call(effect);
    }

    for (int i = 0; i < stepCount; i++) {
      await Future.delayed(stepDelay);
      if (state.isDisposed) return;

      for (final w in wheels) {
        final step = w.steps[i];
        engine.grid[step.row][step.col].emoji = Emojis.bomb;
        engine.grid[step.row][step.col].clearBehavior();
      }
      state.updateUI();
    }

    await Future.delayed(tailDelay);
    if (state.isDisposed) return;

    for (final w in wheels) {
      for (final step in w.steps) {
        engine.grid[step.row][step.col].isTriggered = true;
      }
    }
    state.updateUI();

    final Set<TileCoordinate> staleOrigins = {for (final w in wheels) w.origin};
    await _settleBoard(staleOrigins);
  }

  bool _anySwallowPending() {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        final tile = engine.grid[r][c];
        if (tile.isSwallowTrigger || tile.isSwallowTarget) return true;
      }
    }
    return false;
  }

  Future<bool> _executeEmojiBehaviors() async {
    final drained = await _removeBehaviorFlags();

    if (drained.swallowDestroyed.isNotEmpty) {
      state.announcer.evaluateTurn(
        events: {TurnEvent.blackHole},
        combo: state.currentComboMultiplier,
        tilesCleared: drained.swallowDestroyed.length,
      );
    }

    return drained.didAnything;
  }

  Future<
    ({
      Set<TileCoordinate> swallowDestroyed,
      Set<TileCoordinate> lineClearDestroyed,
      bool didAnything,
    })
  >
  _removeBehaviorFlags() async {
    Set<TileCoordinate> swallowDestroyed = {};
    Set<TileCoordinate> lineClearDestroyed = {};
    final List<({int row, int col, bool isHorizontal})> lineClearTriggers = [];

    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        final tile = engine.grid[r][c];
        if (tile.isSwallowTarget || tile.isSwallowTrigger) {
          swallowDestroyed.add(TileCoordinate(row: r, col: c));
          engine.grid[r][c].isSwallowTarget = false;
          engine.grid[r][c].isSwallowTrigger = false;
        }

        if (tile.isRowClearTrigger) {
          lineClearTriggers.add((row: r, col: c, isHorizontal: true));
        }
        if (tile.isColClearTrigger) {
          lineClearTriggers.add((row: r, col: c, isHorizontal: false));
        }

        if (tile.isLineClearTrigger || tile.isLineClearTarget) {
          lineClearDestroyed.add(TileCoordinate(row: r, col: c));
        }
      }
    }

    final bool didAnything =
        swallowDestroyed.isNotEmpty || lineClearDestroyed.isNotEmpty;

    if (swallowDestroyed.isNotEmpty) {
      if (await _settleBoard(swallowDestroyed) == null) {
        return (
          swallowDestroyed: swallowDestroyed,
          lineClearDestroyed: lineClearDestroyed,
          didAnything: false,
        );
      }
    }

    if (lineClearDestroyed.isNotEmpty) {
      state.updateUI();

      await Future.delayed(lineClearBeamDuration);
      if (state.isDisposed) {
        return (
          swallowDestroyed: swallowDestroyed,
          lineClearDestroyed: lineClearDestroyed,
          didAnything: false,
        );
      }

      for (final trigger in lineClearTriggers) {
        onLineClear?.call(trigger.row, trigger.col, trigger.isHorizontal);
      }

      await Future.delayed(preShatterDelay);
      if (state.isDisposed) {
        return (
          swallowDestroyed: swallowDestroyed,
          lineClearDestroyed: lineClearDestroyed,
          didAnything: false,
        );
      }

      for (final coord in lineClearDestroyed) {
        engine.grid[coord.row][coord.col].isLineClearTrigger = false;
        engine.grid[coord.row][coord.col].isLineClearTarget = false;
        engine.grid[coord.row][coord.col].isRowClearTrigger = false;
        engine.grid[coord.row][coord.col].isColClearTrigger = false;
      }

      if (await _settleBoard(lineClearDestroyed) == null) {
        return (
          swallowDestroyed: swallowDestroyed,
          lineClearDestroyed: lineClearDestroyed,
          didAnything: false,
        );
      }
    }

    return (
      swallowDestroyed: swallowDestroyed,
      lineClearDestroyed: lineClearDestroyed,
      didAnything: didAnything,
    );
  }

  Future<void> _cascadeSequence(TileCoordinate focusCoordinate) async {
    state.announcer.clear();
    state.setComboMultiplier(0);
    state.resetTilesCleared();

    final Set<TurnEvent> events = {};

    while (true) {
      bool cascadeOccurred = await _executeCascadePhase(focusCoordinate);
      if (state.isDisposed) return;

      if (cascadeOccurred) {
        events.add(TurnEvent.merge);
      }
      if (state.hasLegendaryEmoji) {
        events.add(TurnEvent.legendaryEmoji);
        state.setLegendaryEmoji(false);
      }

      bool detonationOccurred = await _executeDetonatorPhase();
      if (state.isDisposed) return;

      if (detonationOccurred) {
        events.add(TurnEvent.explosion);
      }

      if (_anyWheelPending()) {
        await _executeWheelPhase(
          isHorizontal: true,
          isWrapping: true,
          triggerCoord: focusCoordinate,
        );
        if (state.isDisposed) return;
        continue;
      }

      if (_anyGhostPending()) {
        await _executeGhostPhase();
        if (state.isDisposed) return;
        continue;
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

  Future<bool> _executeCascadePhase(TileCoordinate targetCoordinate) async {
    bool isFirstMatch = true;
    bool executionOccurred = false;
    Set<int> affectedColumns = {};
    Set<int> affectedRows = {};
    bool hadLegendaryEmo = false;

    while (true) {
      await _waitIfPaused();
      if (state.isDisposed) return false;

      final matchedGroups = (affectedColumns.isEmpty || affectedRows.isEmpty)
          ? MatchDetector.findMatchedGroups(boardManager.gridTiles)
          : MatchDetector.findMatchesInVectors(
              grid: boardManager.gridTiles,
              affectedColumns: affectedColumns,
              affectedRows: affectedRows,
            );

      final removed = <MatchGroup>[];
      matchedGroups.removeWhere((group) {
        final blocked = group.coordinates.any((c) {
          final tile = engine.grid[c.row][c.col];
          return tile.isTriggered || tile.isExploding || tile.isMerging;
        });
        if (blocked) removed.add(group);
        return blocked;
      });
      if (removed.isNotEmpty) {
        _log.warning(
          'Removed ${removed.length} groups due to dirty flags: ${removed.map((g) => '${g.emoji.visual}:${g.coordinates.length}').join(', ')}',
        );
      }

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

      await Future.delayed(matchFreezeDuration);
      if (state.isDisposed) return false;

      final stepResult = engine.processCascadeStep(
        matchedGroups: matchedGroups,
        targetCoordinate: targetCoordinate,
        isFirstMatch: isFirstMatch,
      );

      _resolveCollectedEmojis(stepResult.collectedEmojis);
      boardManager.flagFlyingTargetEmojis(stepResult.tilesToDestroy);
      await _removeBehaviorFlags();
      if (state.isDisposed) return false;

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
        await Future.delayed(matchFreezeDuration);
        boardManager.clearTransmutingFlags();
      } else {
        await Future.delayed(emptyTransmuteDelay);
      }

      final Set<TileCoordinate> allDestroyed = {
        ...stepResult.tilesToDestroy,
        ...mergedFlyingTargets,
      };

      final gravityDeltas = await _settleBoard(
        allDestroyed,
        clearFlyingFlags: true,
      );
      if (gravityDeltas == null) return false;
      affectedColumns = gravityDeltas.cols;
      affectedRows = gravityDeltas.rows;

      isFirstMatch = false;
    }

    if (hadLegendaryEmo) {
      state.setLegendaryEmoji(true);
    }

    return executionOccurred;
  }

  Future<bool> _executeDetonatorPhase() async {
    bool executionOccurred = false;

    while (true) {
      List<Tile> primedBombs = boardManager.getTriggeredEmojis();
      if (primedBombs.isEmpty) break;

      executionOccurred = true;
      await _waitIfPaused();
      if (state.isDisposed) return false;

      final stepResult = engine.processDetonationStep();
      _resolveCollectedEmojis(stepResult.collectedEmojis);

      Set<TileCoordinate> targetFlyingTransforms = {};
      for (var coord in stepResult.transformed) {
        final tile = engine.grid[coord.row][coord.col];
        _resolveCollectedEmojis([CollectedEmoji(emoji: tile.emoji, count: 1)]);
        if (tile.emoji == engine.level.targetEmoji) {
          tile.isFlying = true;
          targetFlyingTransforms.add(coord);
        }
      }

      boardManager.flagFlyingTargetEmojis(stepResult.destroyed);
      state.updateUI();

      await Future.delayed(matchFreezeDuration);
      if (state.isDisposed) return false;

      final Set<TileCoordinate> blastDestroyed = {
        ...stepResult.destroyed,
        ...targetFlyingTransforms,
      };

      if (await _settleBoard(blastDestroyed, clearFlyingFlags: true) == null) {
        return false;
      }

      engine.processPendingBlasts();

      Set<TileCoordinate> behaviorDestroyed = {};
      for (int r = 0; r < BoardManager.rows; r++) {
        for (int c = 0; c < BoardManager.cols; c++) {
          final tile = engine.grid[r][c];
          if (tile.isSwallowTarget || tile.isSwallowTrigger) {
            behaviorDestroyed.add(TileCoordinate(row: r, col: c));
          }
        }
      }

      if (behaviorDestroyed.isNotEmpty) {
        state.updateUI();
        await Future.delayed(dynamicBehaviorLock);
        if (state.isDisposed) return false;
        for (final coord in behaviorDestroyed) {
          engine.grid[coord.row][coord.col].isSwallowTarget = false;
          engine.grid[coord.row][coord.col].isSwallowTrigger = false;
        }

        if (await _settleBoard(behaviorDestroyed) == null) return false;
      }

      Set<TileCoordinate> lineClearDestroyed = {};
      for (int r = 0; r < BoardManager.rows; r++) {
        for (int c = 0; c < BoardManager.cols; c++) {
          final tile = engine.grid[r][c];

          if (tile.isRowClearTrigger) {
            onLineClear?.call(r, c, true);
          }
          if (tile.isColClearTrigger) {
            onLineClear?.call(r, c, false);
          }

          if (tile.isLineClearTrigger || tile.isLineClearTarget) {
            lineClearDestroyed.add(TileCoordinate(row: r, col: c));
          }
        }
      }

      if (lineClearDestroyed.isNotEmpty) {
        state.updateUI();
        for (final coord in lineClearDestroyed) {
          engine.grid[coord.row][coord.col].isLineClearTrigger = false;
          engine.grid[coord.row][coord.col].isLineClearTarget = false;
          engine.grid[coord.row][coord.col].isRowClearTrigger = false;
          engine.grid[coord.row][coord.col].isColClearTrigger = false;
        }

        if (await _settleBoard(lineClearDestroyed) == null) return false;
      }
    }

    return executionOccurred;
  }

  Future<void> _finalizeTurnLifecycle() async {
    if (!engine.hasPossibleMoves() && !state.isGameOver && !state.isFeverTime) {
      await shuffleBoard();
    }

    _clearWheelTriggers();

    _log.info('Processing After Turn Emoji Behaviors...');
    engine.processTurnEndBehaviors();
    state.updateUI();

    await Future.delayed(const Duration(milliseconds: 400));
    if (state.isDisposed) return;
    boardManager.clearShufflingFlags();

    await Future.delayed(turnEndInputUnlockDelay);
    if (state.isDisposed) return;

    state.setHasTargetCombo(false);
    state.setProcessing(false);

    if (!state.isDisposed) {
      state.updateUI();
      unawaited(_triggerHint());
      resetHintTimer();
      await onComboFinished();
    }
  }

  void _resolveCollectedEmojis(List<CollectedEmoji> collections) {
    for (var collection in collections) {
      if (collection.emoji == engine.level.targetEmoji) {
        state.setHasTargetCombo(true);
        onTargetAcquired(collection.count);
      }
    }
    state.updateUI();
  }

  Future<void> _waitIfPaused() async {
    while (state.isPaused && !state.isDisposed) {
      await Future.delayed(postSwipeScanDelay);
    }
  }

  Future<({Set<int> cols, Set<int> rows})?> _settleBoard(
    Set<TileCoordinate> destroyed, {
    bool clearFlyingFlags = false,
  }) async {
    final deltas = boardManager.applyGravity(destroyed);
    final dirtyAfterGravity = engine.grid
        .expand((row) => row)
        .where(
          (t) =>
              t.isMerging || t.isMergePoint || t.isExploding || t.isTriggered,
        )
        .toList();
    if (dirtyAfterGravity.isNotEmpty) {
      _log.warning(
        'Dirty flags after gravity: ${dirtyAfterGravity.map((t) => '${t.emoji.visual}(${t.coordinate.row},${t.coordinate.col}) M=${t.isMerging} P=${t.isMergePoint} E=${t.isExploding} T=${t.isTriggered}').join(', ')}',
      );
    }
    engine.initializeBehaviors();
    if (clearFlyingFlags) boardManager.clearAllFlyingFlags();
    state.updateUI();

    await Future.delayed(postFallSettleDelay);
    if (state.isDisposed) return null;

    boardManager.triggerInitialFall();
    state.updateUI();

    await Future.delayed(fallDuration);
    if (state.isDisposed) return null;

    return deltas;
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
}
