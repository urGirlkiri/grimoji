import 'dart:async';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/features/game/board/models/coordinate.dart';
import 'package:grimoji/features/game/board/models/tile.dart';
import 'package:grimoji/features/game/board/utils/manager.dart';
import 'package:grimoji/features/game/engines/game_engine.dart';
import 'package:grimoji/features/game/model/collected_emoji.dart';
import 'package:grimoji/features/game/utils/match_detector.dart';
import 'package:grimoji/features/game/state.dart';
import 'package:grimoji/features/game/utils/swipe_detector.dart';
import 'package:logging/logging.dart';

class GameCoordinator {
  final GameEngine engine;
  final GameState state;
  final BoardManager boardManager;
  final void Function(int) onTargetAcquired;
  final bool Function() onComboFinished;
  final Logger _log = Logger('GameCoordinator');

  Timer? _hintTimer;
  List<TileCoordinate>? _currentHints;

  GameCoordinator({
    required this.engine,
    required this.state,
    required this.boardManager,
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

  Future<void> resolveSwipe(
    TileCoordinate dCoord,
    TileCoordinate tCoord,
  ) async {
    if (state.isGameOver || state.isPaused) return;

    state.setProcessing(true);
    resetHintTimer();

    final decision = engine.evaluateSwipe(dCoord, tCoord);

    if (decision.type == SwipeResult.invalid) {
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

    state.updateUI();
    await Future.delayed(const Duration(milliseconds: 100));
    if (state.isDisposed) return;

    if (decision.type == SwipeResult.specialBehavior) {
      engine.executeBehaviorActions(decision.actions, dCoord.row, dCoord.col);
      state.setProcessing(false);
      state.updateUI();
      resetHintTimer();
      return;
    }

    state.announcer.clear();
    state.setComboMultiplier(0);
    bool turnHadAlchemy = false;
    bool turnHadCalamity = false;

    while (true) {
      int comboBeforeCascade = state.currentComboMultiplier;

      bool cascadeOccurred = await executeCascadePhase(tCoord);
      if (state.isDisposed) return;

      if (cascadeOccurred &&
          state.currentComboMultiplier > comboBeforeCascade) {
        turnHadAlchemy = true;
      }

      List<Tile> primedBombs = engine.getTriggeredBombs();
      if (primedBombs.isNotEmpty) {
        if (state.currentComboMultiplier > 0) {
          triggerComboAnnouncement(state.currentComboMultiplier);
          state.setComboMultiplier(0);
        } else if (turnHadAlchemy) {
          state.announcer.announce("Alchemy!");
          turnHadAlchemy = false;
        }
      }

      bool detonationOccurred = await executeDetonatorPhase();
      if (state.isDisposed) return;
      if (detonationOccurred) {
        turnHadCalamity = true;
      }

      if (!cascadeOccurred && !detonationOccurred) {
        break;
      }
    }

    if (state.currentComboMultiplier > 0) {
      triggerComboAnnouncement(state.currentComboMultiplier);
    } else if (turnHadCalamity) {
      state.announcer.announce("Calamity!");
    } else if (turnHadAlchemy) {
      state.announcer.announce("Alchemy!");
    }

    await finalizeTurnLifecycle();
  }

  Future<bool> executeCascadePhase(TileCoordinate targetCoordinate) async {
    bool isFirstMatch = true;
    bool executionOccurred = false;

    while (true) {
      await waitIfPaused();
      final matchedGroups = MatchDetector.findMatchedGroups(boardManager.gridTiles);

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

      await evaluateAlchemicalJuice(matchedGroups, stepResult.tilesToDestroy);

      final Set<TileCoordinate> allDestroyed = {
        ...stepResult.tilesToDestroy,
        ...mergedFlyingTargets,
      };

      boardManager.applyGravity(allDestroyed);
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

    return executionOccurred;
  }

  Future<bool> executeDetonatorPhase() async {
    bool executionOccurred = false;

    while (true) {
      List<Tile> primedBombs = engine.getTriggeredBombs();
      if (primedBombs.isEmpty) break;

      executionOccurred = true;
      await waitIfPaused();

      final stepResult = engine.processDetonationStep();
      resolveCollectedEmojis(stepResult.collectedEmojis);

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
      };

      boardManager.clearTransmutingFlags();
      boardManager.applyGravity(allDestroyed);
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

  Future<void> finalizeTurnLifecycle() async {
    if (!engine.hasPossibleMoves()) {
      _log.info('NO MOVES LEFT! Shuffling...');
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
      onComboFinished();
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

  void triggerComboAnnouncement(int comboMultiplier) {
    if (comboMultiplier == 1) {
      state.announcer.announce("Wicked!");
    } else if (comboMultiplier == 2) {
      state.announcer.announce("Diabolical!");
    } else if (comboMultiplier == 3) {
      state.announcer.announce("Sorcery!");
    } else if (comboMultiplier >= 4) {
      state.announcer.announce("MAGICAL!!");
    }
  }

  Future<void> evaluateAlchemicalJuice(
    List<MatchGroup> groups,
    Set<TileCoordinate> destroyed,
  ) async {
    final Set<TileCoordinate> matches = groups
        .expand((g) => g.coordinates)
        .toSet();
    bool hasAoE = destroyed.any(
      (coord) => !matches.any((c) => c.row == coord.row && c.col == coord.col),
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
  }

  Future<void> shuffleBoard() async {
    state.setShuffleProgress(0.0);
    state.setShuffling(true);

    await Future.delayed(const Duration(milliseconds: 600));
    engine.shuffleGrid();

    state.setShuffleProgress(1.0);
    state.updateUI();

    await Future.delayed(const Duration(milliseconds: 600));
    state.setShuffling(false);

    if (!state.isDisposed) {
      resetHintTimer();
    }
  }

  void resetHintTimer() {
    if (state.isDisposed || state.isGameOver) {
      _hintTimer?.cancel();
      return;
    }

    clearHint();
    if (!state.isProcessing && !state.isShuffling) {
      _hintTimer?.cancel();
      _hintTimer = Timer(const Duration(seconds: 5), _triggerHint);
    }
  }

  void _triggerHint() {
    if (state.isProcessing ||
        state.isShuffling ||
        state.isDisposed ||
        state.isGameOver) {
      return;
    }

    _currentHints = engine.getHintMove();
    if (_currentHints != null) {
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
    while (state.isPaused) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void togglePause() {
    state.setPaused(!state.isPaused);
  }

  void cancelHintTimer() {
    _hintTimer?.cancel();
  }

  void dispose() {
    cancelHintTimer();
    state.dispose();
  }
}
