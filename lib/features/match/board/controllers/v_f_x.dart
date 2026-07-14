import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/board/effect/manager.dart';
import 'package:grimoji/features/match/board/effects/ghost_dive/effect.dart';
import 'package:grimoji/features/match/board/effects/line_clear/effect.dart';
import 'package:grimoji/features/match/board/effects/punch/effect.dart';
import 'package:grimoji/features/match/board/effects/sparkle/effect.dart';
import 'package:grimoji/features/match/board/effects/time_bonus/effect.dart';
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
  final punchManager = EffectManager<PunchEffect>(
    lifetime: const Duration(milliseconds: 400),
  );
  final timeBonusManager = EffectManager<TimeBonusEffect>(
    lifetime: timeBonusDuration,
  );

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
    state.coordinator.onPunch = (coord) {
      if (!_isDisposed) punchManager.trigger(PunchEffect(target: coord));
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
  }

  void unbindState(LevelState state) {
    state.coordinator.onLineClear = null;
    state.coordinator.onWheelRoll = null;
    state.coordinator.onGhostDive = null;
    state.onTimeBonus = null;
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
    punchManager.dispose();
    timeBonusManager.dispose();
  }
}
