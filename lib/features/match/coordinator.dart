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
import 'package:grimoji/features/match/processors/settlement.dart';
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
  late final SettlementProcessor _settlement;

  GameCoordinator({
    required this.engine,
    required this.state,
    required this.boardManager,
    required this.audio,
    required this.onTargetAcquired,
    required this.onComboFinished,
    required List<String> startingBoosters,
  }) {
    _settlement = SettlementProcessor(
      engine: engine,
      state: state,
      boardManager: boardManager,
    );
    state.setHintsEnabled(startingBoosters.contains('crystal_ball'));
  }

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
      if (!await _safeDelay(swallowAnimationLock)) return;
    }

    if (!await _processEffects(
      isHorizontal: true,
      isWrapping: true,
      triggerCoord: coord,
    )) {
      return;
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

      if (!await _safeDelay(swapSpeed)) return;

      boardManager.swapTiles(tCoord, dCoord);
      state.updateUI();

      state.setHasTargetCombo(false);
      state.setProcessing(false);
      resetHintTimer();
      return;
    }

    audio.playSfx(SfxType.swipe);

    state.updateUI();
    if (!await _safeDelay(postSwipeScanDelay)) return;

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
        if (!await _safeDelay(swallowAnimationLock)) return;
      }

      if (!await _processEffects(
        isHorizontal: isHorizontal,
        isWrapping: isPositive,
        triggerCoord: triggerCoord,
      )) {
        return;
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

    if (!await _safeDelay(shuffleWipeHalfTime)) return;

    engine.shuffleGrid();

    state.setShuffleProgress(1.0);
    state.updateUI();

    if (!await _safeDelay(shuffleWipeHalfTime)) return;

    state.setShuffling(false);

    if (!state.isFeverTime) {
      resetHintTimer();
    }
  }

  void resetHintTimer() {
    if (state.isDisposed ||
        state.isGameOver ||
        state.isFeverTime ||
        !state.hintsEnabled) {
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

    _forEachTile((_, _, tile) {
      tile.isHinting = false;
      tile.hintPartner = null;
    });
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
    _forEachTile((_, _, tile) {
      tile.isWheelTrigger = false;
    });
  }

  bool _anyGhostPending() =>
      _hasTileWhere((t) => t.isGhostTrigger || t.isGhostOrigin);

  Future<void> _executeGhostPhase() async {
    final triggers = _handleGhostTriggers();
    if (triggers.isEmpty) return;

    final result = await _handleGhostDive(triggers);
    if (state.isDisposed) return;

    await _handleGhostSettlement(result.destroyed, result.newBombs);
  }

  bool _anyWheelPending() => _hasTileWhere((t) => t.isWheelTrigger);

  List<({TileCoordinate origin, bool isBomb, TileCoordinate? bombOrigin})>
  _handleGhostTriggers() {
    final triggers =
        <({TileCoordinate origin, bool isBomb, TileCoordinate? bombOrigin})>[];
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
    return triggers;
  }

  Future<({Set<TileCoordinate> destroyed, Set<TileCoordinate> newBombs})>
  _handleGhostDive(
    List<({TileCoordinate origin, bool isBomb, TileCoordinate? bombOrigin})>
    triggers,
  ) async {
    final Set<TileCoordinate> destroyed = {};
    final Set<TileCoordinate> newBombs = {};

    for (final trigger in triggers) {
      final origin = trigger.origin;
      final target = await BoardEvaluator.findTarget(
        grid: engine.grid,
        targetEmoji: engine.level.targetEmoji,
      );
      if (state.isDisposed) return (destroyed: destroyed, newBombs: newBombs);
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
        if (!await _safeDelay(ghostDiveDuration)) {
          return (destroyed: destroyed, newBombs: newBombs);
        }
      }

      await diveAnimation;
      if (state.isDisposed) return (destroyed: destroyed, newBombs: newBombs);

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

    return (destroyed: destroyed, newBombs: newBombs);
  }

  Future<void> _handleGhostSettlement(
    Set<TileCoordinate> destroyed,
    Set<TileCoordinate> newBombs,
  ) async {
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
      await _settlement.settleBoard(destroyed);
    } else {
      await Future.delayed(preShatterDelay);
    }
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
          wheels.add((origin: origin, steps: steps));
        }
      }
    }
    if (wheels.isEmpty) return;

    for (final w in wheels) {
      engine.grid[w.origin.row][w.origin.col].isWheelOrigin = true;
      engine.grid[w.origin.row][w.origin.col].clearBehavior();
    }
    state.updateUI();

    if (!await _safeDelay(wheelWindUpDuration)) return;

    for (final w in wheels) {
      final effect = RollEffect(
        startRow: w.origin.row,
        startCol: w.origin.col,
        isHorizontal: isHorizontal,
        isWrapping: isWrapping,
        steps: w.steps,
      );
      onWheelRoll?.call(effect);
    }

    for (int i = 0; i < stepCount; i++) {
      if (!await _safeDelay(stepDelay)) return;

      for (final w in wheels) {
        final step = w.steps[i];
        engine.grid[step.row][step.col].emoji = Emojis.bomb;
        engine.grid[step.row][step.col].clearBehavior();
      }
      state.updateUI();
    }

    if (!await _safeDelay(tailDelay)) return;

    for (final w in wheels) {
      for (final step in w.steps) {
        engine.grid[step.row][step.col].isTriggered = true;
      }
    }
    state.updateUI();

    final Set<TileCoordinate> staleOrigins = {for (final w in wheels) w.origin};
    await _settlement.settleBoard(staleOrigins);
  }

  bool _anySwallowPending() =>
      _hasTileWhere((t) => t.isSwallowTrigger || t.isSwallowTarget);

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
      if (await _settlement.settleBoard(swallowDestroyed) == null) {
        return _emptyDrainResult(swallowDestroyed, lineClearDestroyed);
      }
    }

    if (lineClearDestroyed.isNotEmpty) {
      if (!await _refreshAndWait(lineClearBeamDuration)) {
        return _emptyDrainResult(swallowDestroyed, lineClearDestroyed);
      }

      for (final trigger in lineClearTriggers) {
        onLineClear?.call(trigger.row, trigger.col, trigger.isHorizontal);
      }

      await Future.delayed(preShatterDelay);
      if (state.isDisposed) {
        return _emptyDrainResult(swallowDestroyed, lineClearDestroyed);
      }

      for (final coord in lineClearDestroyed) {
        engine.grid[coord.row][coord.col].isLineClearTrigger = false;
        engine.grid[coord.row][coord.col].isLineClearTarget = false;
        engine.grid[coord.row][coord.col].isRowClearTrigger = false;
        engine.grid[coord.row][coord.col].isColClearTrigger = false;
      }

      if (await _settlement.settleBoard(lineClearDestroyed) == null) {
        return _emptyDrainResult(swallowDestroyed, lineClearDestroyed);
      }
    }

    return (
      swallowDestroyed: swallowDestroyed,
      lineClearDestroyed: lineClearDestroyed,
      didAnything: didAnything,
    );
  }

  Future<void> _cascadeSequence(TileCoordinate focusCoordinate) async {
    await _runCoreCascadeLoop(focusCoordinate);
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

      if (!await _handleMatchAnimations(
        matchedGroups,
        isFirstMatch,
        targetCoordinate,
      )) {
        return false;
      }

      final stepResult = engine.processCascadeStep(
        matchedGroups: matchedGroups,
        targetCoordinate: targetCoordinate,
        isFirstMatch: isFirstMatch,
      );

      final mergedFlyingTargets = await _handleFlyingTargets(
        stepResult.collectedEmojis,
        stepResult.tilesToDestroy,
      );
      if (state.isDisposed) return false;

      final tilesCleared =
          stepResult.tilesToDestroy.length + mergedFlyingTargets.length;
      state.addTilesCleared(tilesCleared);

      for (var coord in stepResult.transformed) {
        final tile = engine.grid[coord.row][coord.col];
        if (RecipeBook.isLegendary(tile.emoji)) {
          hadLegendaryEmo = true;
        }
      }

      final gravityDeltas = await _settlement.afterCascade(
        stepResult.tilesToDestroy,
        mergedFlyingTargets,
        matchedGroups,
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

      final targetFlyingTransforms = _handleTargetFlyingTransforms(
        stepResult.transformed,
      );

      boardManager.flagFlyingTargetEmojis(stepResult.destroyed);
      state.updateUI();

      await Future.delayed(matchFreezeDuration);
      if (state.isDisposed) return false;

      final Set<TileCoordinate> blastDestroyed = {
        ...stepResult.destroyed,
        ...targetFlyingTransforms,
      };

      if (!await _settlement.afterDetonation(blastDestroyed)) {
        return false;
      }

      if (await _handleDetonationBehaviorDrain()) {
        continue;
      }
    }

    return executionOccurred;
  }

  Future<void> _finalizeTurnLifecycle() async {
    if (!engine.hasPossibleMoves() && !state.isGameOver && !state.isFeverTime) {
      await shuffleBoard();
    }

    _clearWheelTriggers();

    engine.processTurnEndBehaviors();
    state.updateUI();

    if (!await _safeDelay(clownShuffleDuration)) return;
    boardManager.clearShufflingFlags();

    await _processClownMatches();
    if (state.isDisposed) return;

    if (!await _safeDelay(turnEndInputUnlockDelay)) return;

    state.setHasTargetCombo(false);
    state.setProcessing(false);

    if (!state.isDisposed) {
      state.updateUI();
      resetHintTimer();
      await onComboFinished();
    }
  }

  Future<void> _processClownMatches() async {
    await _runCoreCascadeLoop(TileCoordinate(row: 3, col: 2));
  }

  Future<void> _runCoreCascadeLoop(TileCoordinate focusCoordinate) async {
    state.announcer.clear();
    state.setComboMultiplier(0);
    state.resetTilesCleared();

    final Set<TurnEvent> events = {};

    while (true) {
      bool cascadeOccurred = await _executeCascadePhase(focusCoordinate);
      if (state.isDisposed) return;

      bool detonationOccurred = await _executeDetonatorPhase();
      if (state.isDisposed) return;

      _recordTurnEvents(
        events: events,
        cascadeOccurred: cascadeOccurred,
        detonationOccurred: detonationOccurred,
      );

      if (!await _processEffects(
        isHorizontal: true,
        isWrapping: true,
        triggerCoord: focusCoordinate,
      )) {
        return;
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

  bool _hasTileWhere(bool Function(Tile tile) predicate) {
    for (final row in engine.grid) {
      for (final tile in row) {
        if (predicate(tile)) return true;
      }
    }
    return false;
  }

  void _forEachTile(void Function(int row, int col, Tile tile) action) {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        action(r, c, engine.grid[r][c]);
      }
    }
  }

  Future<bool> _safeDelay(Duration duration) async {
    await Future.delayed(duration);
    return !state.isDisposed;
  }

  Future<bool> _refreshAndWait(Duration duration) async {
    state.updateUI();
    await Future.delayed(duration);
    return !state.isDisposed;
  }

  Set<TileCoordinate> _collectFlyingTargets({Set<TileCoordinate>? excluding}) {
    final result = <TileCoordinate>{};

    _forEachTile((r, c, tile) {
      if (!tile.isFlying) return;

      if (excluding?.contains(TileCoordinate(row: r, col: c)) ?? false) {
        return;
      }

      result.add(TileCoordinate(row: r, col: c));
    });

    return result;
  }

  Future<bool> _handleDetonationBehaviorDrain() async {
    final drainResult = await _removeBehaviorFlags();
    if (state.isDisposed) return false;
    return drainResult.didAnything;
  }

  Set<TileCoordinate> _handleTargetFlyingTransforms(
    Set<TileCoordinate> transformed,
  ) {
    final targetFlyingTransforms = <TileCoordinate>{};
    for (var coord in transformed) {
      final tile = engine.grid[coord.row][coord.col];
      _resolveCollectedEmojis([CollectedEmoji(emoji: tile.emoji, count: 1)]);
      if (tile.emoji == engine.level.targetEmoji) {
        tile.isFlying = true;
        targetFlyingTransforms.add(coord);
      }
    }
    return targetFlyingTransforms;
  }

  Future<Set<TileCoordinate>> _handleFlyingTargets(
    List<CollectedEmoji> collectedEmojis,
    Set<TileCoordinate> tilesToDestroy,
  ) async {
    _resolveCollectedEmojis(collectedEmojis);
    boardManager.flagFlyingTargetEmojis(tilesToDestroy);
    await _removeBehaviorFlags();
    final mergedFlyingTargets = _collectFlyingTargets(
      excluding: tilesToDestroy,
    );
    state.updateUI();
    return mergedFlyingTargets;
  }

  Future<bool> _handleMatchAnimations(
    List<MatchGroup> matchedGroups,
    bool isFirstMatch,
    TileCoordinate targetCoordinate,
  ) async {
    engine.categorizeAnimations(matchedGroups, isFirstMatch, targetCoordinate);
    return await _refreshAndWait(matchFreezeDuration);
  }

  void _recordTurnEvents({
    required Set<TurnEvent> events,
    required bool cascadeOccurred,
    required bool detonationOccurred,
  }) {
    if (cascadeOccurred) {
      events.add(TurnEvent.merge);
    }

    if (detonationOccurred) {
      events.add(TurnEvent.explosion);
    }

    if (state.hasLegendaryEmoji) {
      events.add(TurnEvent.legendaryEmoji);
      state.setLegendaryEmoji(false);
    }
  }

  Future<bool> _processEffects({
    required bool isHorizontal,
    required bool isWrapping,
    required TileCoordinate triggerCoord,
  }) async {
    if (_anyWheelPending()) {
      await _executeWheelPhase(
        isHorizontal: isHorizontal,
        isWrapping: isWrapping,
        triggerCoord: triggerCoord,
      );
      if (state.isDisposed) return false;
    }

    if (_anyGhostPending()) {
      await _executeGhostPhase();
      if (state.isDisposed) return false;
    }

    return true;
  }

  ({
    Set<TileCoordinate> swallowDestroyed,
    Set<TileCoordinate> lineClearDestroyed,
    bool didAnything,
  })
  _emptyDrainResult(
    Set<TileCoordinate> swallow,
    Set<TileCoordinate> lineClear,
  ) => (
    swallowDestroyed: swallow,
    lineClearDestroyed: lineClear,
    didAnything: false,
  );
}
