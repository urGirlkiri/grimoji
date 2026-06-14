import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

class TimeManager {
  final int timeLimit;
  final VoidCallback onTick;
  final VoidCallback onTimeUp;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _ticker;
  bool _isDisposed = false;
  int _lastNotifiedSeconds = -1;

  TimeManager({
    required this.timeLimit,
    required this.onTick,
    required this.onTimeUp,
  });

  int get secondsRemaining => max(0, timeLimit - _stopwatch.elapsed.inSeconds);

  void start() {
    if (_isDisposed) return;
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || !_stopwatch.isRunning) return;

      final current = secondsRemaining;
      if (current != _lastNotifiedSeconds) {
        _lastNotifiedSeconds = current;
        onTick();
      }

      if (current <= 0) {
        onTimeUp();
      }
    });
  }

  void pause() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    }
  }

  void resume() {
    if (!_stopwatch.isRunning && !_isDisposed) {
      _stopwatch.start();
    }
  }

  void stop() {
    _stopwatch.stop();
    _ticker?.cancel();
  }

  void dispose() {
    _isDisposed = true;
    _ticker?.cancel();
    _stopwatch.stop();
  }
}
