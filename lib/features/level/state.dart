import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/game/state.dart';
import 'package:logging/logging.dart';

class LevelState extends ChangeNotifier {
  final void Function(int stars) onWin;
  final VoidCallback onLose;
  final GameLevel level;

  final Stopwatch _stopwatch = Stopwatch();
  final Logger _log = Logger('LevelState');
  final GlobalKey targetIconKey = GlobalKey();
  Timer? _ticker;

  late final GameState gameState;

  LevelState({required this.onWin, required this.onLose, required this.level}) {
    gameState = GameState(
      level: level,
      onEmojiDestroyed: _onEmojiDestroyed,
      onComboFinished: _evaluateGameEnd,
    );

    gameState.addListener(notifyListeners);
  }

  bool isPaused = false;
  bool _isDisposed = false;
  bool _isGameOver = false;
  int collectedAmount = 0;

  int get secondsRemaining => max(0, level.timeLimit - _stopwatch.elapsed.inSeconds);
  double get progress => (collectedAmount / level.targetAmount).clamp(0.0, 1.0);

  void startLevel() {
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTimerTick());
    gameState.startInitialDrop();
  }

  void _onTimerTick() {
    if (_isDisposed || !_stopwatch.isRunning) return;

    notifyListeners();

    if (secondsRemaining <= 0) {
      _evaluateGameEnd();
    }
  }

  void _onEmojiDestroyed(GameEmoji emoji, int count) {
    if (emoji == level.targetEmoji) {
      collectedAmount += count;
      notifyListeners();
    }
  }

  bool _evaluateGameEnd() {
    if (_isGameOver) return true;

    bool shouldEnd = progress >= 1.0 || secondsRemaining <= 0;
    _log.info("Level check: progress=${progress.toStringAsFixed(2)}, time=${secondsRemaining}s, shouldEnd=$shouldEnd");

    if (shouldEnd) {
      _isGameOver = true;
      gameState.setGameOver();
      _ticker?.cancel();
      _stopwatch.stop();

      int earnedStars = 0;

      if (progress >= 1.0) {
        if (progress >= 1.00) earnedStars = 3;
        if (progress >= 0.66) earnedStars = 2;
        if (progress >= 0.33) earnedStars = 1;
        
        int timeBonus = secondsRemaining * 10;
        _log.info("GAME OVER! Earned $earnedStars stars. Time Bonus: $timeBonus. YOU WIN!");
        
        if (earnedStars >= 1) {
          gameState.hasTargetCombo = true;
          onWin.call(earnedStars);
        } else {
          onLose.call();
        }
      } else {
        onLose.call();
      }
    }

    return true;
  }

  void togglePause() {
    gameState.togglePause();
    isPaused = gameState.isPaused;
    isPaused ? _stopwatch.stop() : _stopwatch.start();
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _ticker?.cancel();
    _stopwatch.stop();
    gameState.removeListener(notifyListeners);
    gameState.dispose();
    super.dispose();
  }
}
