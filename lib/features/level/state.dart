import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grimoji/app/lifecycle.dart';
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
  final AppLifecycleStateNotifier lifecycleNotifier;

  final GlobalKey targetIconKey = GlobalKey();

  final Stopwatch _timeLimitStopwatch = Stopwatch();
  Timer? _ticker;

  late final BoardManager boardManager;
  late final GameEngine engine;
  late final GameState gameState;
  late final GameCoordinator coordinator;

  int collectedAmount = 0;
  bool _isDisposed = false;

  LevelState({
    required this.onWin,
    required this.onLose,
    required this.level,
    required this.audio,
    required this.lifecycleNotifier,
  }) {
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
    gameState.addListener(_onGameStateChanged);
    lifecycleNotifier.addListener(_onLifecycleChanged);
  }

  void _onLifecycleChanged() {
    final state = lifecycleNotifier.value;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      if (!gameState.isPaused && !gameState.isGameOver) {
        coordinator.togglePause();
      }
    }
  }

  void _onGameStateChanged() {
    if (gameState.isPaused || gameState.isProcessing || gameState.isGameOver) {
      if (_timeLimitStopwatch.isRunning) {
        _timeLimitStopwatch.stop();
      }
    } else {
      if (!_timeLimitStopwatch.isRunning && !_isDisposed) {
        _timeLimitStopwatch.start();
      }
    }
  }

  void _incrementCollectedAmnt(int count) {
    collectedAmount += count;
    notifyListeners();

    if (progress >= 1.0 && !gameState.isFeverTime) {
      _evaluateGameEndAsync();
    }
  }

  Future<bool> _evaluateGameEndAsync() async {
    if (gameState.isGameOver) return true;

    if (progress >= 1.0 && !gameState.isFeverTime) {
      await _triggerFever();
      return false;
    }

    if (secondsRemaining <= 0) {
      gameState.setGameOver();
      coordinator.cancelHintTimer();
      _ticker?.cancel();
      _timeLimitStopwatch.stop();
      notifyListeners();

      while (gameState.isProcessing ||
          gameState.announcer.isSpeaking ||
          gameState.isShuffling) {
        await Future.delayed(const Duration(milliseconds: 250));
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (_isDisposed) return true;

      coordinator.clearHint();
      audio.playMenuMusic();
      onLose.call();
    }

    return false;
  }

  Future<void> _triggerFever() async {
    gameState.setFeverTime(true);
    _timeLimitStopwatch.stop();
    _ticker?.cancel();
    coordinator.cancelHintTimer();

    int bonusBombs = (secondsRemaining / 5).floor();

    while (gameState.isProcessing) {
      await Future.delayed(const Duration(milliseconds: 250));
    }

    if (bonusBombs > 0) {
      boardManager.spawnBombs(bonusBombs);
      gameState.updateUI();
      await Future.delayed(const Duration(seconds: 1));

      boardManager.triggerAllBombs();
      await coordinator.executeDetonatorPhase();

      while (gameState.isProcessing) {
        await Future.delayed(const Duration(milliseconds: 250));
      }
    }

    gameState.setGameOver();

    while (gameState.isProcessing ||
        gameState.announcer.isSpeaking ||
        gameState.isShuffling) {
      await Future.delayed(const Duration(milliseconds: 250));
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (_isDisposed) return;

    coordinator.clearHint();
    audio.playMenuMusic();

    int earnedStars = 3;
    gameState.setHasTargetCombo(true);
    onWin.call(earnedStars);
  }

  int get secondsRemaining =>
      max(0, level.timeLimit - _timeLimitStopwatch.elapsed.inSeconds);

  double get progress => (collectedAmount / level.targetAmount).clamp(0.0, 1.0);

  int _lastNotifiedSeconds = -1;

  void startLevel() {
    audio.playLevelMusic();
    _timeLimitStopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), ((timer) {
      if (_isDisposed || !_timeLimitStopwatch.isRunning) return;

      final currentSeconds = secondsRemaining;
      if (currentSeconds != _lastNotifiedSeconds) {
        _lastNotifiedSeconds = currentSeconds;
        notifyListeners();
      }

      if (secondsRemaining <= 0) {
        _evaluateGameEndAsync();
      }
    }));

    coordinator.startInitialDrop();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _ticker?.cancel();
    _timeLimitStopwatch.stop();
    gameState.removeListener(notifyListeners);
    gameState.removeListener(_onGameStateChanged);
    lifecycleNotifier.removeListener(_onLifecycleChanged);
    coordinator.dispose();
    super.dispose();
  }
}
