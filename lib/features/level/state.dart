import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:grimoji/config/levels.dart';
import 'package:grimoji/features/level/game/controller.dart';
import 'package:grimoji/features/level/game/model/coordinate.dart';
import 'package:grimoji/features/level/game/model/match_detector.dart';
import 'package:logging/logging.dart';

class LevelState extends ChangeNotifier {
  final void Function(int stars) onWin;
  final VoidCallback onFail;
  final GameLevel level;

  final Stopwatch _stopwatch = Stopwatch();
  final Logger _log = Logger('LevelState');

  late final GameController gameController;
  late int _secondsRemaining = level.timeLimit;

  LevelState({required this.onWin, required this.onFail, required this.level}) {
    gameController = GameController(level);
    gameController.initialize();
  }

  Timer? _ticker;

  bool isProcessing = false;
  bool isPaused = false;

  int get secondsRemaining => _secondsRemaining;

  void startLevel() {
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_stopwatch.isRunning) {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          _secondsRemaining = 0;
          stopLevel();
          onFail();
        }
        notifyListeners();
      }
    });
  }

  void startInitialDrop() async {
    _log.info('Starting to drop emojis');
    startLevel();
    gameController.triggerInitialFall();
    notifyListeners();
  }

  void togglePause() {
    isPaused = !isPaused;
    _log.info('Toggling pause. Currently paused: $isPaused');
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
    }
    notifyListeners();
  }

  void onBoardUpdated() {
    notifyListeners();
  }


  Future<void> resolveSwipe(TileCoordinate a, TileCoordinate b) async {
    isProcessing = true; 
    notifyListeners();

    gameController.swapTiles(a, b);
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300)); 

    Set<TileCoordinate> matches = MatchDetector.findMatches(gameController.grid);

    if (matches.isEmpty) {
      _log.info('Invalid Move! Reverting swap.');
      gameController.swapTiles(b, a);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 300));
      
      isProcessing = false; 
      notifyListeners();
      return;
    }

    bool hasCombos = true;
    while (hasCombos) {
      _log.info('Found ${matches.length} matches! Triggering Avalanche...');
      
      gameController.spawnTiles(matches);
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 50));
      gameController.triggerInitialFall();
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 800)); 

      matches = MatchDetector.findMatches(gameController.grid);
      if (matches.isEmpty) {
        hasCombos = false; 
      } else {
        _log.info('COMBO DETECTED! Looping again...');
      }
    }

    isProcessing = false;
    notifyListeners();
  }
  void stopLevel() {
    _stopwatch.stop();
    _ticker?.cancel();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

}
