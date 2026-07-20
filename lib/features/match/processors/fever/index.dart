import 'dart:async';
import 'dart:math';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behavior_register.dart';
import 'package:grimoji/features/alchemy/models/action_type.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/match/controllers/hint.dart';
import 'package:grimoji/features/match/detectors/match.dart';
import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/processors/effects/index.dart';
import 'package:grimoji/features/match/processors/effects/models/pending_ghost_dive.dart';
import 'package:grimoji/features/match/state.dart';

class FeverProcessor {
  final GameEngine engine;
  final GameState state;
  final BoardManager boardManager;
  final EffectsProcessor effects;
  final HintController hint;
  final Future<void> Function(TileCoordinate) cascadeSequence;
  final Future<bool> Function({
    required bool isHorizontal,
    required bool isWrapping,
  })
  processEffects;
  final Future<bool> Function(
    List<PendingGhostDive> ghosts, {
    required bool simultaneous,
  })
  dispatchGhostEffects;
  final Future<bool> Function() sweepBehaviors;

  bool _skipRequested = false;

  FeverProcessor({
    required this.engine,
    required this.state,
    required this.boardManager,
    required this.effects,
    required this.hint,
    required this.cascadeSequence,
    required this.processEffects,
    required this.dispatchGhostEffects,
    required this.sweepBehaviors,
  });

  bool get _shouldAbort => _skipRequested || state.isDisposed;

  Future<void> _ensureBoardSettled() async {
    if (_shouldAbort) return;
    if (MatchDetector.findMatchedGroups(boardManager.gridTiles).isEmpty &&
        boardManager.getTriggeredEmojis().isEmpty) {
      return;
    }

    await cascadeSequence(TileCoordinate(row: 3, col: 3));
    while (state.isProcessing && !_shouldAbort) {
      await Future<void>.delayed(flagPollingInterval);
    }
  }

  void skip() {
    _skipRequested = true;
  }

  Future<bool> executeSequence({
    required int bonusBombs,
    required void Function() onSpawn,
  }) async {
    _beginFever(bonusBombs);
    var completed = false;

    try {
      completed = await _runSequence(bonusBombs, onSpawn);
      return completed;
    } finally {
      _finishFever(completed);
    }
  }

  void _beginFever(int bonusBombs) {
    _skipRequested = false;
    state.setFeverComplete(false);
    state.setFeverTime(true);
    state.setFeverBombCount(bonusBombs);
    state.setReFeverBombs(bonusBombs);
    state.setFeverTimer(bonusBombs);
    hint.cancel();
    hint.clear();
  }

  void _finishFever(bool completed) {
    state.setFeverTime(false);
    if (completed) {
      state.setFeverComplete(true);
    }
    hint.cancel();
    hint.clear();
  }

  Future<bool> _runSequence(int bonusBombs, void Function() onSpawn) async {
    while (state.isProcessing && !_shouldAbort) {
      await Future<void>.delayed(flagPollingInterval);
    }
    if (_shouldAbort) return false;

    if (!await _executeAutoTriggers()) return false;

    for (var index = 0; index < bonusBombs; index++) {
      if (_shouldAbort) return false;
      await _ensureBoardSettled();
      if (_shouldAbort) return false;
      boardManager.spawnBomb();
      onSpawn();
      state.updateUI();
      await Future<void>.delayed(feverBombSpawnInterval);
    }

    if (bonusBombs == 0) return !_shouldAbort;

    await Future<void>.delayed(feverDetonationChainDelay);
    for (var index = 0; index < bonusBombs; index++) {
      if (_shouldAbort || boardManager.countSafeBombs() == 0) break;

      final primedBombs = boardManager.getTriggeredEmojis();
      final focusCoordinate = primedBombs.isNotEmpty
          ? primedBombs.first.coordinate
          : TileCoordinate(row: 3, col: 3);

      boardManager.triggerNextBomb();
      state.updateUI();
      await Future<void>.delayed(feverDetonationChainDelay);
      if (_shouldAbort) return false;

      await cascadeSequence(focusCoordinate);
      while (state.isProcessing && !_shouldAbort) {
        await Future<void>.delayed(flagPollingInterval);
      }
      if (_shouldAbort) return false;

      if (!await _executeAutoTriggers()) return false;

      state.setReFeverBombs(boardManager.countSafeBombs());
      state.decrementFeverTimer();
      state.updateUI();
      await Future<void>.delayed(feverClockTickInterval);
    }

    return !_shouldAbort;
  }

  Future<bool> _executeAutoTriggers() async {
    if (!await _executeGhostFever()) return false;
    if (!await _executeBlackHoleFever()) return false;
    if (!await _executePoleFever()) return false;
    return await _executeWheelFever();
  }

  Future<bool> _executeGhostFever() async {
    final safeTargets = <GameEmoji>{
      engine.level.targetEmoji,
      ...engine.level.availableEmojis,
    }..remove(Emojis.bomb);

    final excluded = <TileCoordinate>{};
    for (var row = 0; row < BoardManager.rows; row++) {
      for (var col = 0; col < BoardManager.cols; col++) {
        if (!safeTargets.contains(engine.grid[row][col].emoji)) {
          excluded.add(TileCoordinate(row: row, col: col));
        }
      }
    }

    for (var row = 0; row < BoardManager.rows; row++) {
      for (var col = 0; col < BoardManager.cols; col++) {
        if (engine.grid[row][col].emoji == Emojis.ghost) {
          engine.executeBehaviorActions(
            [const BehaviorAction(type: ActionType.ghostDive)],
            row,
            col,
          );
        }
      }
    }

    if (_shouldAbort) return false;
    return await dispatchGhostEffects(
      await effects.prepareGhostEffects(excluded: excluded),
      simultaneous: true,
    );
  }

  Future<bool> _executeBlackHoleFever() async {
    final blackHoles = <TileCoordinate>[];
    for (var row = 0; row < BoardManager.rows; row++) {
      for (var col = 0; col < BoardManager.cols; col++) {
        if (engine.grid[row][col].emoji == Emojis.hole) {
          blackHoles.add(TileCoordinate(row: row, col: col));
        }
      }
    }
    if (blackHoles.isEmpty) return !_shouldAbort;

    final specialEmojis = {
      Emojis.bomb,
      Emojis.hole,
      Emojis.barberPole,
      Emojis.ghost,
      Emojis.wheel,
    };
    final blackHoleCoordinates = blackHoles
        .map((coordinate) => (coordinate.row, coordinate.col))
        .toSet();
    final presentTypes = <GameEmoji>{};

    for (var row = 0; row < BoardManager.rows; row++) {
      for (var col = 0; col < BoardManager.cols; col++) {
        if (blackHoleCoordinates.contains((row, col))) continue;
        final emoji = engine.grid[row][col].emoji;
        if (!specialEmojis.contains(emoji)) presentTypes.add(emoji);
      }
    }
    if (presentTypes.isEmpty) return !_shouldAbort;

    final chosenEmoji = presentTypes.elementAt(
      Random().nextInt(presentTypes.length),
    );
    for (final coordinate in blackHoles) {
      engine.executeBehaviorActions(
        [BehaviorAction(type: ActionType.consumeAllOfType, emoji: chosenEmoji)],
        coordinate.row,
        coordinate.col,
      );
    }

    state.updateUI();
    await Future<void>.delayed(swallowAnimationLock);
    if (_shouldAbort) return false;
    await sweepBehaviors();
    return !_shouldAbort;
  }

  Future<bool> _executePoleFever() async {
    engine.initializeBehaviors();
    final poles = <TileCoordinate>[];
    for (var row = 0; row < BoardManager.rows; row++) {
      for (var col = 0; col < BoardManager.cols; col++) {
        if (engine.grid[row][col].emoji == Emojis.barberPole) {
          poles.add(TileCoordinate(row: row, col: col));
        }
      }
    }
    if (poles.isEmpty) return !_shouldAbort;

    for (final coordinate in poles) {
      final actions = engine.processTappedBehavior(
        engine.grid[coordinate.row][coordinate.col],
        coordinate.row,
        coordinate.col,
      );
      if (actions.isEmpty) {
        final fallback = BehaviorRegister.getBehaviorFor(Emojis.barberPole);
        if (fallback != null) {
          engine.executeBehaviorActions(
            fallback.onTapped(coordinate.row, coordinate.col),
            coordinate.row,
            coordinate.col,
          );
        }
      } else {
        engine.executeBehaviorActions(actions, coordinate.row, coordinate.col);
      }
    }

    await sweepBehaviors();
    return !_shouldAbort;
  }

  Future<bool> _executeWheelFever() async {
    engine.initializeBehaviors();
    final wheels = <TileCoordinate>[];
    for (var row = 0; row < BoardManager.rows; row++) {
      for (var col = 0; col < BoardManager.cols; col++) {
        if (engine.grid[row][col].emoji == Emojis.wheel) {
          wheels.add(TileCoordinate(row: row, col: col));
        }
      }
    }
    if (wheels.isEmpty) return !_shouldAbort;

    for (final coordinate in wheels) {
      engine.executeBehaviorActions(
        [const BehaviorAction(type: ActionType.wheelRoll)],
        coordinate.row,
        coordinate.col,
      );
    }

    return await processEffects(
      isHorizontal: Random().nextBool(),
      isWrapping: Random().nextBool(),
    );
  }
}
