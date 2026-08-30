import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/board/effect/manager.dart';
import 'package:grimoji/features/match/board/effects/blood_drop/effect.dart';
import 'package:grimoji/features/match/board/effects/ghost_dive/effect.dart';
import 'package:grimoji/features/match/board/effects/line_clear/effect.dart';
import 'package:grimoji/features/match/board/effects/sparkle/effect.dart';
import 'package:grimoji/features/match/board/effects/test_tube/effect.dart';
import 'package:grimoji/features/match/board/effects/time_bonus/effect.dart';
import 'package:grimoji/features/match/board/effects/ufo/effect.dart';
import 'package:grimoji/features/match/board/effects/wheel_roll/effect.dart';
import 'package:grimoji/features/match/constants.dart';

class VFXController {
  final sparkleManager = EffectManager<SparkleEffect>(
    lifetime: sparkleLifetime,
  );
  final lineClearManager = EffectManager<LineClearEffect>(
    lifetime: lineClearDuration,
  );
  final wheelRollManager = EffectManager<RollEffect>(
    lifetime: wheelRollDuration,
  );
  final ghostDiveManager = EffectManager<GhostDiveEffect>(
    lifetime: ghostDiveDuration,
  );
  final timeBonusManager = EffectManager<TimeBonusEffect>(
    lifetime: timeBonusDuration,
  );
  final bloodDropManager = EffectManager<BloodDropEffect>(
    lifetime: bloodDropLifetime,
  );
  final testTubeManager = EffectManager<TestTubeEffect>(
    lifetime: testTubeDropLifetime,
  );
  final ufoManager = EffectManager<UFOEffect>(lifetime: ufoLifetime);

  bool _isDisposed = false;
  double? _boardWidth;
  double? _boardHeight;

  void setBoardDimensions(double width, double height) {
    _boardWidth = width;
    _boardHeight = height;
  }

  void bindState(LevelState state) {
    state.coordinator.onLineClear = (row, col, isHoriz) {
      if (!_isDisposed) {
        lineClearManager.trigger(
          LineClearEffect(row: row, col: col, isHorizontal: isHoriz),
        );
      }
    };
    state.coordinator.onWheelRoll = (effect) {
      if (!_isDisposed) wheelRollManager.trigger(effect);
      return Future.delayed(const Duration(microseconds: 0));
    };
    state.coordinator.onGhostDive = (effect) {
      if (!_isDisposed) ghostDiveManager.trigger(effect);
      return Future.delayed(const Duration(microseconds: 0));
    };
    state.onTimeBonus = (amount) {
      if (!_isDisposed && _boardWidth != null && _boardHeight != null) {
        final centerX = _boardWidth! / 2;
        final centerY = _boardHeight! / 2;
        final centerPosition = Offset(centerX, centerY);
        timeBonusManager.trigger(
          TimeBonusEffect(position: centerPosition, amount: amount),
        );
      }
    };
    state.onBloodDrop = (coord) {
      if (!_isDisposed) {
        bloodDropManager.trigger(BloodDropEffect(coord: coord));
      }
    };
    state.onTestTube = (coord) {
      if (!_isDisposed) {
        testTubeManager.trigger(TestTubeEffect(coord: coord));
      }
    };
  }

  void unbindState(LevelState state) {
    state.coordinator.onLineClear = null;
    state.coordinator.onWheelRoll = null;
    state.coordinator.onGhostDive = null;
    state.onTimeBonus = null;
    state.onBloodDrop = null;
    state.onTestTube = null;
    state.onUFO = null;
  }

  void triggerSparkle(Offset localPosition) {
    if (!_isDisposed) {
      sparkleManager.trigger(SparkleEffect(position: localPosition));
    }
  }

  void triggerTimeBonus(Offset position, int amount) {
    if (!_isDisposed) {
      timeBonusManager.trigger(
        TimeBonusEffect(position: position, amount: amount),
      );
    }
  }

  void dispose() {
    _isDisposed = true;
    sparkleManager.dispose();
    lineClearManager.dispose();
    wheelRollManager.dispose();
    ghostDiveManager.dispose();
    timeBonusManager.dispose();
    bloodDropManager.dispose();
    testTubeManager.dispose();
    ufoManager.dispose();
  }
}
