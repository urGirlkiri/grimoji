// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// An extremely silly example of a game state.
///
/// Tracks only a single variable, [progress], and calls [onWin] when
/// the value of [progress] reaches [goal].
class LevelState extends ChangeNotifier {
  final VoidCallback onWin;
  final VoidCallback onFail;

  final String goal;
  final int maxMoves;

  LevelState({
    required this.onWin,
    required this.onFail,
    required this.goal,
    required this.maxMoves,
  });

  int _progress = 0;
  // ignore: unused_field
  int _movesUsed = 0;

  int get progress => _progress;

  void setProgress(int value) {
    _progress = value;
    _movesUsed++;
    notifyListeners();
    evaluate();
  }

  void evaluate() {
    // if (_progress >= goal) {
    //   onWin();
    // } else if (_movesUsed >= maxMoves) {
    //   onFail();
    // }
  }
}
