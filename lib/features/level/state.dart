import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/game/board/utils/manager.dart';
import 'package:grimoji/features/game/engines/game_engine.dart';
import 'package:grimoji/features/game/coordinator.dart';
import 'package:grimoji/features/game/state.dart';
import 'package:logging/logging.dart';

class LevelState extends ChangeNotifier {
  final void Function(int stars) onWin;
  final VoidCallback onLose;
  final GameLevel level;

  final GlobalKey targetIconKey = GlobalKey();

  final Stopwatch _timeLimitStopwatch = Stopwatch();
  final Logger _log = Logger('LevelState');
  Timer? _ticker;

  late final BoardManager boardManager;
  late final GameEngine engine;
  late final GameState gameState;
  late final GameCoordinator coordinator;

  LevelState({required this.onWin, required this.onLose, required this.level}) {
    boardManager = BoardManager(level);
    engine = GameEngine(level: level, boardManager: boardManager);
    engine.initialize();

    gameState = GameState();

    coordinator = GameCoordinator(
      engine: engine,
      state: gameState,
      boardManager: boardManager,
      onTargetAcquired: _incrementCollectedAmnt,
      onComboFinished: _evaluateGameEnd,
    );

    gameState.addListener(notifyListeners);
  }

  bool isPaused = false;
  bool _isDisposed = false;
  bool _isGameOver = false;
  int collectedAmount = 0;

  int get secondsRemaining =>
      max(0, level.timeLimit - _timeLimitStopwatch.elapsed.inSeconds);

  double get progress => (collectedAmount / level.targetAmount).clamp(0.0, 1.0);

  void startLevel() {
    _timeLimitStopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), ((timer) {
      if (_isDisposed || !_timeLimitStopwatch.isRunning) return;

      notifyListeners();

      if (secondsRemaining <= 0) {
        _evaluateGameEnd();
      }
    }));

    coordinator.startInitialDrop();
  }

  void _incrementCollectedAmnt(int count) {
    collectedAmount += count;
    notifyListeners();
  }

  bool _evaluateGameEnd() {
    if (_isGameOver) return true;

    bool shouldEnd = progress >= 1.0 || secondsRemaining <= 0;
    _log.info(
      "Level check: progress=${progress.toStringAsFixed(2)}, time=${secondsRemaining}s, shouldEnd=$shouldEnd",
    );

    if (shouldEnd) {
      _isGameOver = true;
      gameState.setGameOver();
      coordinator.cancelHintTimer();
      _ticker?.cancel();
      _timeLimitStopwatch.stop();

      int earnedStars = progress >= 1.0
          ? 3
          : progress >= 0.66
          ? 2
          : progress >= 0.33
          ? 1
          : 0;

      // ignore: unused_local_variable
      int timeBonus = (secondsRemaining / 10).round();

      if (earnedStars > 0) {
        gameState.setHasTargetCombo(true);
        onWin.call(earnedStars);
      } else {
        onLose.call();
      }
    }

    return false;
  }

  void togglePause() {
    coordinator.togglePause();
    isPaused = gameState.isPaused;
    isPaused ? _timeLimitStopwatch.stop() : _timeLimitStopwatch.start();
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _ticker?.cancel();
    _timeLimitStopwatch.stop();
    gameState.removeListener(notifyListeners);
    coordinator.dispose();
    super.dispose();
  }
}
