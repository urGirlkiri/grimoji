import 'package:flutter/material.dart';
import 'package:grimoji/app/lifecycle.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/match/utils/manager.dart';
import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/coordinator.dart';
import 'package:grimoji/features/match/state.dart';
import 'managers/time.dart';
import 'managers/goal.dart';

class LevelState extends ChangeNotifier {
  final void Function(int stars) onWin;
  final VoidCallback onLose;
  final GameLevel level;
  final AudioController audio;
  final AppLifecycleStateNotifier lifecycleNotifier;
  final List<String> startingBoosters;

  final GlobalKey targetIconKey = GlobalKey();

  late final TimeManager timeManager;
  late final GoalManager goalManager;
  static const int bonusTime = 5;

  late final BoardManager boardManager;
  late final GameEngine engine;
  late final GameState gameState;
  late final GameCoordinator coordinator;

  bool _isDisposed = false;

  LevelState({
    required this.onWin,
    required this.onLose,
    required this.level,
    required this.audio,
    required this.lifecycleNotifier,
    this.startingBoosters = const [],
  }) {
    goalManager = GoalManager(targetAmount: level.targetAmount);
    timeManager = TimeManager(
      timeLimit: level.timeLimit,
      onTick: notifyListeners,
      onTimeUp: _handleTimeUp,
    );

    boardManager = BoardManager(level, playSfx: audio.playSfx);
    engine = GameEngine(
      level: level,
      boardManager: boardManager,
      playSfx: audio.playSfx,
    );
    engine.initialize();
    if (startingBoosters.isNotEmpty) {
      boardManager.placeStartingBoosters(startingBoosters);
      engine.initializeBehaviors();
    }

    gameState = GameState(audio);
    coordinator = GameCoordinator(
      engine: engine,
      state: gameState,
      boardManager: boardManager,
      audio: audio,
      onTargetAcquired: _incrementCollectedAmnt,
      onComboFinished: () async => false,
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
      timeManager.pause();
    } else {
      timeManager.resume();
    }
  }

  void _incrementCollectedAmnt(int count) async {
    if (goalManager.isComplete) return;

    goalManager.add(count);
    notifyListeners();

    if (goalManager.isComplete && !gameState.isFeverTime) {
      timeManager.stop();
    }
  }

  Future<void> startFeverSequence() async {
    if (_isDisposed || gameState.isGameOver || gameState.isFeverTime) return;

    while (gameState.isProcessing || gameState.isShuffling) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    int bonusBombs = (timeManager.secondsRemaining / bonusTime).floor();

    coordinator
        .executeFeverSequence(bonusBombs, () {
          timeManager.removeTime(bonusTime);
        })
        .then((_) {
          if (_isDisposed) return;

          audio.playMenuMusic();
          gameState.setHasTargetCombo(true);
          onWin.call(goalManager.calculateStars());
        });
  }

  void skipFeverAndComplete() {
    if (_isDisposed) return;
    audio.playMenuMusic();
    gameState.setHasTargetCombo(true);
    onWin.call(goalManager.calculateStars());
  }

  void triggerFeverForTesting() {
    if (gameState.isFeverTime || gameState.isGameOver) return;
    timeManager.stop();
    goalManager.add(level.targetAmount);
    notifyListeners();
    startFeverSequence();
  }

  void _handleTimeUp() async {
    if (gameState.isFeverTime || goalManager.isComplete) return;

    gameState.setGameOver();
    coordinator.cancelHintTimer();
    notifyListeners();

    while (gameState.isProcessing ||
        gameState.announcer.isSpeaking ||
        gameState.isShuffling) {
      await Future.delayed(const Duration(milliseconds: 250));
    }
    await Future.delayed(const Duration(milliseconds: 500));

    if (_isDisposed) return;

    coordinator.clearHint();
    audio.playMenuMusic();
    onLose.call();
  }

  void pauseTimer() => timeManager.pause();
  void resumeTimerOnly() {
    if (!gameState.isPaused && !gameState.isGameOver) timeManager.resume();
  }

  bool get isGoalComplete => goalManager.isComplete;

  int get secondsRemaining => timeManager.secondsRemaining;
  double get progress => goalManager.progress;
  int get collectedAmount => goalManager.collectedAmount;

  void startLevel() {
    audio.playLevelMusic();
    timeManager.start();
    coordinator.startInitialDrop();
  }

  @override
  void dispose() {
    _isDisposed = true;
    timeManager.dispose();
    gameState.removeListener(notifyListeners);
    gameState.removeListener(_onGameStateChanged);
    lifecycleNotifier.removeListener(_onLifecycleChanged);
    coordinator.dispose();
    super.dispose();
  }
}
