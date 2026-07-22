import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grimoji/app/lifecycle.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/coordinator.dart';
import 'package:grimoji/features/match/state.dart';
import 'package:grimoji/features/match/announcer.dart';
import 'package:grimoji/features/level/managers/time.dart';
import 'package:grimoji/features/level/managers/goal.dart';
import 'package:logging/logging.dart';

class LevelState extends ChangeNotifier {
  static final _log = Logger('LevelState');
  final void Function(int stars) onWin;
  final VoidCallback onLose;
  final GameLevel level;
  final AudioController audio;
  final AppLifecycleStateNotifier lifecycleNotifier;
  final List<String> startingBoosters;

  final GlobalKey targetIconKey = GlobalKey();
  final GlobalKey powerupIconKey = GlobalKey();
  Offset? _powerupIconPosition;

  Offset? get powerupIconPosition => _powerupIconPosition;

  late final TimeManager timeManager;
  late final GoalManager goalManager;
  static const int bonusTime = 5;

  late final BoardManager boardManager;
  late final GameEngine engine;
  late final GameState gameState;
  late final BoardAnnouncer announcer;
  late final GameCoordinator coordinator;

  bool _isDisposed = false;
  Completer<TileCoordinate>? _powerupSelectionCompleter;
  TileCoordinate? _powerupHoverTarget;
  Powerup? _selectedPowerup;
  int _powerupHoverToken = 0;
  bool _isPowerupAnimating = false;
  TileCoordinate? _punchTarget;
  Completer<void>? _punchAnimationCompleter;

  int get powerupHoverToken => _powerupHoverToken;

  bool get isPowerupAnimating => _isPowerupAnimating;
  TileCoordinate? get punchTarget => _punchTarget;

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

    gameState = GameState();
    announcer = BoardAnnouncer(audio);
    announcer.addListener(notifyListeners);

    coordinator = GameCoordinator(
      engine: engine,
      state: gameState,
      boardManager: boardManager,
      audio: audio,
      announcer: announcer,
      onTargetAcquired: _incrementCollectedAmnt,
      onComboFinished: () async => false,
      startingBoosters: startingBoosters,
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
    } else if (state == AppLifecycleState.resumed) {
      if (gameState.isPaused && !gameState.isGameOver) {
        boardManager.settleTileCoordinates();
        coordinator.togglePause();
        gameState.updateUI();
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

  void _handleTimeUp() async {
    if (gameState.isFeverTime || goalManager.isComplete) return;

    gameState.setGameOver();
    coordinator.cancelHintTimer();
    notifyListeners();

    while (gameState.isProcessing ||
        announcer.isSpeaking ||
        gameState.isShuffling) {
      await Future.delayed(const Duration(milliseconds: 250));
    }
    await Future.delayed(const Duration(milliseconds: 500));

    if (_isDisposed) return;

    coordinator.clearHint();
    audio.playMenuMusic();

    final starsEarned = goalManager.calculateStars();
    if (starsEarned >= 1) {
      onWin.call(starsEarned);
    } else {
      onLose.call();
    }
  }

  bool get isPowerupSelecting => _powerupSelectionCompleter != null;
  Powerup? get selectedPowerup => _selectedPowerup;

  Future<TileCoordinate> awaitPowerupTile(Powerup powerup) {
    _log.fine('Starting tile selection for powerup=${powerup.id}');
    _selectedPowerup = powerup;
    _powerupSelectionCompleter = Completer<TileCoordinate>();
    coordinator.clearHint();
    notifyListeners();
    return _powerupSelectionCompleter!.future;
  }

  void onPowerTileTapped(TileCoordinate coord) {
    final completer = _powerupSelectionCompleter;
    _log.fine(
      'Tile selection received: row=${coord.row}, col=${coord.col}, '
      'hasCompleter=${completer != null}, completed=${completer?.isCompleted}',
    );
    if (completer == null || completer.isCompleted) {
      _log.warning('Ignoring powerup tile tap without an active selection');
      return;
    }
    _capturePowerupPosition();
    _punchTarget = coord;
    boardManager.gridTiles[coord.row][coord.col].isPowerupTarget = true;
    completer.complete(coord);
    _powerupSelectionCompleter = null;
    _selectedPowerup = null;
    notifyListeners();
  }

  void _capturePowerupPosition() {
    final renderBox =
        powerupIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      _powerupIconPosition =
          position +
          Offset(renderBox.size.width / 2, renderBox.size.height / 2);
      _log.fine('Captured powerup icon position: $_powerupIconPosition');
    } else {
      _powerupIconPosition = null;
    }
  }

  Future<void> startPowerupAnimation() {
    _isPowerupAnimating = true;
    _punchAnimationCompleter = Completer<void>();
    notifyListeners();
    return _punchAnimationCompleter!.future;
  }

  void markPunchImpact() {
    final target = _punchTarget;
    if (target != null) {
      boardManager.gridTiles[target.row][target.col].isExploding = true;
      gameState.updateUI();
      notifyListeners();
    }
  }

  void completePowerupAnimation() {
    _isPowerupAnimating = false;
    _powerupIconPosition = null;
    _punchTarget = null;
    _punchAnimationCompleter?.complete();
    _punchAnimationCompleter = null;
    notifyListeners();
  }

  void updatePowerupHoverTarget(TileCoordinate? coord) {
    if (_powerupHoverTarget == coord) return;
    _clearPowerupTargetFlags();
    if (coord != null) {
      _powerupHoverTarget = coord;
      boardManager.gridTiles[coord.row][coord.col].isPowerupTarget = true;
      _log.fine(
        'Powerup target set: row=${coord.row}, col=${coord.col}, '
        'token=${_powerupHoverToken + 1}',
      );
    } else {
      _log.fine('Powerup target cleared');
    }
    _powerupHoverToken++;
    notifyListeners();
  }

  void _clearPowerupTargetFlags() {
    if (_powerupHoverTarget != null) {
      boardManager
              .gridTiles[_powerupHoverTarget!.row][_powerupHoverTarget!.col]
              .isPowerupTarget =
          false;
      _powerupHoverTarget = null;
    }
  }

  void cancelPowerupSelection() {
    _log.fine(
      'Cancelling powerup selection: powerup=${_selectedPowerup?.id}, '
      'hasCompleter=${_powerupSelectionCompleter != null}',
    );
    _clearPowerupTargetFlags();
    _powerupSelectionCompleter?.completeError('Cancelled');
    _powerupSelectionCompleter = null;
    _selectedPowerup = null;
    coordinator.resetHintTimer();
    notifyListeners();
  }

  void pauseTimer() => timeManager.pause();
  void resumeTimerOnly() {
    if (!gameState.isPaused && !gameState.isGameOver) timeManager.resume();
  }

  void addTime(int seconds) {
    timeManager.addTime(seconds);
    onTimeBonus?.call(seconds);
    notifyListeners();
  }

  void Function(int amount)? onTimeBonus;

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
    announcer.removeListener(notifyListeners);
    super.dispose();
  }
}
