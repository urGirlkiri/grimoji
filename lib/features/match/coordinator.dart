import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/alchemy/models/action_type.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/match/models/board_region.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/models/match_group.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/processors/effects/models/pending_ghost_dive.dart';
import 'package:grimoji/features/match/types.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/announcer.dart';
import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/models/collected_emoji.dart';
import 'package:grimoji/features/match/detectors/match.dart';
import 'package:grimoji/features/match/state.dart';
import 'package:grimoji/features/match/detectors/swipe.dart';
import 'package:grimoji/features/match/board/effects/ghost_dive/effect.dart';
import 'package:grimoji/features/match/board/effects/wheel_roll/effect.dart';
import 'package:grimoji/features/match/processors/effects/index.dart';
import 'package:grimoji/features/match/processors/fever/index.dart';
import 'package:grimoji/features/match/processors/settlement.dart';
import 'package:grimoji/features/match/controllers/hint.dart';
import 'package:logging/logging.dart';

class GameCoordinator {
  final GameEngine engine;
  final GameState state;
  final BoardManager boardManager;
  final AudioController audio;
  final BoardAnnouncer announcer;

  final void Function(int) onTargetAcquired;
  final Future<bool> Function() onComboFinished;
  void Function(int row, int col, bool isHorizontal)? onLineClear;
  Future<void> Function(RollEffect)? onWheelRoll;
  Future<void> Function(GhostDiveEffect)? onGhostDive;
  void Function({int intrusiveDestroyed, int shapeMerges, int ghostThreats})?
  onCrimsonProgress;
  final Logger _log = Logger('GameCoordinator');

  late final SettlementProcessor _settlement;
  late final EffectsProcessor _effects;
  late final FeverProcessor _fever;
  late final HintController _hint;

  GameCoordinator({
    required this.engine,
    required this.state,
    required this.boardManager,
    required this.audio,
    required this.announcer,
    required this.onTargetAcquired,
    required this.onComboFinished,
    required List<String> startingBoosters,
  }) {
    _settlement = SettlementProcessor(
      engine: engine,
      state: state,
      boardManager: boardManager,
    );

    _effects = EffectsProcessor(
      engine: engine,
      state: state,
      boardManager: boardManager,
      settlement: _settlement,
    );
    _hint = HintController(engine: engine, state: state, audio: audio);
    _fever = FeverProcessor(
      engine: engine,
      state: state,
      boardManager: boardManager,
      effects: _effects,
      hint: _hint,
      cascadeSequence: _cascadeSequence,
      processEffects: ({required isHorizontal, required isWrapping}) =>
          _processEffects(isHorizontal: isHorizontal, isWrapping: isWrapping),
      dispatchGhostEffects: (ghosts, {required simultaneous}) =>
          _dispatchGhostEffects(ghosts, simultaneous: simultaneous),
      sweepBehaviors: _drainBehaviorFlags,
    );
    state.setHintsEnabled(startingBoosters.contains('crystal_ball'));
  }

  void initialize() {
    engine.initialize();
    _hint.reset();
  }

  void startInitialDrop() {
    boardManager.triggerInitialFall();
    state.updateUI();
    _hint.reset();
  }

  Future<void> resolveTap(TileCoordinate coord) async {
    if (state.isGameOver || state.isPaused) return;

    final tile = engine.grid[coord.row][coord.col];

    final reaction = RecipeBook.getReactionFor(tile.emoji);
    final isExplosive =
        reaction != null && reaction.type == ReactionType.explosive;

    if (isExplosive && !tile.isTriggered) {
      state.setProcessing(true);
      _hint.clear();
      audio.playSfx(SfxType.trigger);
      tile.isTriggered = true;
      state.updateUI();
      await _cascadeSequence(coord);
      return;
    }

    final actions = engine.processTappedBehavior(tile, coord.row, coord.col);

    if (actions.isEmpty) return;

    state.setProcessing(true);
    _hint.clear();

    audio.playSfx(SfxType.swipe);

    engine.executeBehaviorActions(actions, coord.row, coord.col);
    state.updateUI();

    if (_effects.hasSwallowPending) {
      if (!await _safeDelay(swallowAnimationLock)) return;
    }

    if (!await _processEffects(isHorizontal: true, isWrapping: true)) {
      return;
    }

    await _drainBehaviorFlags();
    if (state.isDisposed) return;

    await _cascadeSequence(coord);
  }

  Future<void> resolveSwipe(
    TileCoordinate dCoord,
    TileCoordinate tCoord,
  ) async {
    final dtile = engine.grid[dCoord.row][dCoord.col];

    if (state.isGameOver || state.isPaused) return;

    state.setProcessing(true);
    _hint.clear();

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
      _hint.reset();
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

      final hasSwallow = _effects.hasSwallowPending;
      if (hasSwallow) {
        if (!await _safeDelay(swallowAnimationLock)) return;
      }

      if (!await _processEffects(
        isHorizontal: isHorizontal,
        isWrapping: isPositive,
      )) {
        return;
      }

      await _drainBehaviorFlags();
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
      _hint.reset();
    }
  }

  void togglePause() {
    state.setPaused(!state.isPaused);
  }

  Future<void> executeFeverSequence(
    int bonusBombs,
    VoidCallback onSpawn,
  ) async {
    final completed = await _fever.executeSequence(
      bonusBombs: bonusBombs,
      onSpawn: onSpawn,
    );
    if (!completed || state.isDisposed) return;

    state.setGameOver();
    while ((state.isProcessing || announcer.isSpeaking || state.isShuffling) &&
        !state.isDisposed) {
      await Future<void>.delayed(flagPollingInterval);
    }
    if (state.isDisposed) return;

    await Future<void>.delayed(postFeverResultsDelay);
  }

  void skipFever() {
    state.setGameOver();
    _fever.skip();
  }

  void dispose() {
    _hint.dispose();
    state.dispose();
  }

  void resetHintTimer() => _hint.reset();
  void clearHint() => _hint.clear();
  void cancelHintTimer() => _hint.cancel();

  Future<void> punchTile(TileCoordinate coord) async {
    if (state.isGameOver || state.isPaused || state.isProcessing) return;

    state.setProcessing(true);
    final tile = engine.grid[coord.row][coord.col];
    if (tile.emoji == engine.level.targetEmoji) {
      _resolveCollectedEmojis([CollectedEmoji(emoji: tile.emoji, count: 1)]);
    }

    await _settlement.settleBoard(BoardRegion({coord}));
    await _finalizeTurnLifecycle();
  }

  void bloodDropImpact(TileCoordinate coord) {
    if (state.isGameOver || state.isPaused) return;

    final tile = engine.grid[coord.row][coord.col];
    tile
      ..emoji = Emojis.barberPole
      ..reset()
      ..clearBehavior()
      ..isPowerupTarget = false
      ..isBloodTarget = true;
    engine.initializeBehaviors();
    audio.playSfx(SfxType.transmute);
    state.updateUI();
  }

  Future<void> bloodTile(TileCoordinate coord) async {
    if (state.isGameOver || state.isPaused || state.isProcessing) return;

    state.setProcessing(true);

    final actions = [
      const BehaviorAction(type: ActionType.clearRow),
      const BehaviorAction(type: ActionType.clearCol),
    ];
    engine.executeBehaviorActions(actions, coord.row, coord.col);
    audio.playSfx(SfxType.swipe);
    state.updateUI();

    await _drainBehaviorFlags();
    if (state.isDisposed) return;

    await _cascadeSequence(coord);
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
        state.incrementCombo();
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

      final shapeMerges = matchedGroups.where((g) => g.isSpecial).length;
      final intrusiveCount = _countIntrusive(stepResult.tilesToDestroy);
      onCrimsonProgress?.call(
        shapeMerges: shapeMerges,
        intrusiveDestroyed: intrusiveCount,
      );

      final mergedFlyingTargets = await _handleFlyingTargets(
        stepResult.collectedEmojis,
        stepResult.tilesToDestroy,
      );
      if (state.isDisposed) return false;

      final tilesCleared =
          stepResult.tilesToDestroy.length + mergedFlyingTargets.length;
      state.addClearedTiles(tilesCleared);

      onCrimsonProgress?.call(
        intrusiveDestroyed: _countIntrusive(stepResult.tilesToDestroy),
      );

      for (var coord in stepResult.transformed) {
        final tile = engine.grid[coord.row][coord.col];
        if (RecipeBook.isLegendary(tile.emoji)) {
          hadLegendaryEmo = true;
        }
      }

      final gravityDeltas = await _settlement.afterCascade(
        BoardRegion(stepResult.tilesToDestroy),
        BoardRegion(mergedFlyingTargets),
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

      final TileSet blastDestroyed = {
        ...stepResult.destroyed,
        ...targetFlyingTransforms,
      };

      onCrimsonProgress?.call(
        intrusiveDestroyed: _countIntrusive(blastDestroyed),
      );

      if (!await _settlement.afterDetonation(BoardRegion(blastDestroyed))) {
        return false;
      }

      if (await _handleDetonationBehaviorDrain()) {
        continue;
      }
    }

    return executionOccurred;
  }

  Future<void> _finalizeTurnLifecycle() async {
    if (state.isDisposed) return;
    if (!engine.hasPossibleMoves() && !state.isGameOver && !state.isFeverTime) {
      await shuffleBoard();
    }

    _effects.clearWheelTriggers();

    await engine.processTurnEndBehaviors();
    state.updateUI();

    if (boardManager.hasClownShuffling()) {
      if (!await _safeDelay(clownShuffleDuration)) return;
    }
    boardManager.clearShufflingFlags();

    await _processClownMatches();
    if (state.isDisposed) return;

    if (!await _safeDelay(turnEndInputUnlockDelay)) return;

    state.setHasTargetCombo(false);
    state.setProcessing(false);

    if (!state.isDisposed) {
      state.updateUI();
      _hint.reset();
      await onComboFinished();
    }
  }

  Future<void> _processClownMatches() async {
    await _runCoreCascadeLoop(TileCoordinate(row: 3, col: 2));
  }

  Future<void> _runCoreCascadeLoop(TileCoordinate focusCoordinate) async {
    if (state.isDisposed) return;
    announcer.clear();
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

      if (!await _processEffects(isHorizontal: true, isWrapping: true)) {
        return;
      }

      if (!cascadeOccurred && !detonationOccurred) {
        break;
      }
    }

    announcer.evaluateTurn(
      events: events,
      combo: state.currentComboMultiplier,
      tilesCleared: state.tilesCleared,
    );

    if (announcer.isSpeaking) {
      announcer.startCooldown();
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

  void _forEachTile(void Function(int row, int col, Tile tile) action) {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        action(r, c, engine.grid[r][c]);
      }
    }
  }

  int _countIntrusive(Iterable<TileCoordinate> coords) {
    final intrusive = [Emojis.impSmile, Emojis.clown, Emojis.poop];
    if (intrusive.isEmpty) return 0;
    int count = 0;
    for (final coord in coords) {
      if (intrusive.contains(engine.grid[coord.row][coord.col].emoji)) {
        count++;
      }
    }
    return count;
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

  TileSet _collectFlyingTargets({TileSet? excluding}) {
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
    return await _drainBehaviorFlags();
  }

  TileSet _handleTargetFlyingTransforms(TileSet transformed) {
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

  Future<TileSet> _handleFlyingTargets(
    List<CollectedEmoji> collectedEmojis,
    TileSet tilesToDestroy,
  ) async {
    _resolveCollectedEmojis(collectedEmojis);
    boardManager.flagFlyingTargetEmojis(tilesToDestroy);
    await _drainBehaviorFlags();
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
  }) async {
    if (_effects.hasWheelPending) {
      final wheels = _effects.prepareWheelEffects(
        isHorizontal: isHorizontal,
        isWrapping: isWrapping,
      );
      state.updateUI();
      if (!await _safeDelay(wheelWindUpDuration)) return false;

      for (final wheel in wheels) {
        onWheelRoll?.call(wheel.effect);
      }
      for (var step = 0; step < 3; step++) {
        if (!await _safeDelay(wheelBombDropInterval)) return false;
        _effects.dropWheelBombs(wheels, step);
        state.updateUI();
      }
      if (!await _safeDelay(wheelPostDropPause)) return false;
      if (!await _effects.completeWheelEffects(wheels)) return false;
    }

    if (_effects.hasGhostPending &&
        !await _dispatchGhostEffects(await _effects.prepareGhostEffects())) {
      return false;
    }

    return true;
  }

  Future<bool> _dispatchGhostEffects(
    List<PendingGhostDive> ghosts, {
    bool simultaneous = false,
  }) async {
    if (ghosts.isEmpty) return true;
    final animations = <Future<void>?>[];
    for (final ghost in ghosts) {
      animations.add(onGhostDive?.call(ghost.effect));
      if (!simultaneous) {
        state.updateUI();
        if (!ghost.effect.isBomb && !await _safeDelay(ghostDiveDuration)) {
          return false;
        }
        await animations.last;
        if (state.isDisposed) return false;
      }
    }
    if (simultaneous) {
      state.updateUI();
      if (!await _safeDelay(ghostDiveDuration)) return false;
      for (final animation in animations) {
        await animation;
        if (state.isDisposed) return false;
      }
    }
    _resolveCollectedEmojis(await _effects.completeGhostEffects(ghosts));
    if (ghosts.isNotEmpty) {
      onCrimsonProgress?.call(ghostThreats: ghosts.length);
    }
    return !state.isDisposed;
  }

  Future<bool> _drainBehaviorFlags() async {
    final drained = await _effects.drainBehaviorFlags();
    if (state.isDisposed) return false;

    if (drained.consumedTiles.isNotEmpty) {
      announcer.evaluateTurn(
        events: {TurnEvent.blackHole},
        combo: state.currentComboMultiplier,
        tilesCleared: drained.consumedTiles.length,
      );
    }

    if (drained.clearedLines.isNotEmpty) {
      if (!await _refreshAndWait(lineClearBeamDuration)) return false;
      for (final event in drained.lineClearEvents) {
        onLineClear?.call(event.row, event.col, event.isHorizontal);
      }
      await Future.delayed(preShatterDelay);
      if (state.isDisposed ||
          !await _effects.completeLineClear(drained.clearedLines)) {
        return false;
      }
    }
    return drained.hasBoardChanged;
  }
}
