import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/match/board/utils/manager.dart';
import 'package:grimoji/features/match/engines/game_engine.dart';
import 'package:grimoji/features/match/coordinator.dart';
import 'package:grimoji/features/match/state.dart';

class LevelState extends ChangeNotifier {
  final void Function(int stars) onWin;
  final VoidCallback onLose;
  final GameLevel level;
  final AudioController audio;

  final GlobalKey targetIconKey = GlobalKey();

  final Stopwatch _timeLimitStopwatch = Stopwatch();
  Timer? _ticker;

  late final BoardManager boardManager;
  late final GameEngine engine;
  late final GameState gameState;
  late final GameCoordinator coordinator;

  int collectedAmount = 0;
  bool _isDisposed = false;

  LevelState({required this.onWin, required this.onLose, required this.level, required this.audio}) {
    boardManager = BoardManager(level, playSfx: audio.playSfx);
    engine = GameEngine(
      level: level,
      boardManager: boardManager,
      playSfx: audio.playSfx,
    );
    engine.initialize();

    gameState = GameState(audio);

    coordinator = GameCoordinator(
      engine: engine,
      state: gameState,
      boardManager: boardManager,
      audio: audio,
      onTargetAcquired: _incrementCollectedAmnt,
      onComboFinished: _evaluateGameEndAsync,
    );

    gameState.addListener(notifyListeners);
  }

  bool get isPaused => gameState.isPaused;
  bool get isGameOver => gameState.isGameOver;

  int get secondsRemaining =>
      max(0, level.timeLimit - _timeLimitStopwatch.elapsed.inSeconds);

  double get progress => (collectedAmount / level.targetAmount).clamp(0.0, 1.0);

  void startLevel() {
    audio.playLevelMusic();
    _timeLimitStopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), ((timer) {
      if (_isDisposed || !_timeLimitStopwatch.isRunning) return;

      notifyListeners();

      if (secondsRemaining <= 0) {
        _evaluateGameEndAsync();
      }
    }));

    coordinator.startInitialDrop();
  }

  void _incrementCollectedAmnt(int count) {
    collectedAmount += count;
    notifyListeners();
    
    if (progress >= 1.0) {
      _evaluateGameEndAsync();
    }
  }

  Future<bool> _evaluateGameEndAsync() async {
    if (gameState.isGameOver) return true;

    bool shouldEnd = progress >= 1.0 || secondsRemaining <= 0;

    if (shouldEnd) {
      gameState.setGameOver();
      coordinator.cancelHintTimer();
      _ticker?.cancel();
      _timeLimitStopwatch.stop();
      notifyListeners();

      while (gameState.isProcessing || gameState.announcer.isSpeaking || gameState.isShuffling) {
        await Future.delayed(const Duration(milliseconds: 250));
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (_isDisposed) return true;

      coordinator.clearHint();
      audio.playMenuMusic();

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
    gameState.isPaused ? _timeLimitStopwatch.stop() : _timeLimitStopwatch.start();
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
