import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/board/effect/manager.dart';
import 'package:grimoji/features/match/board/effects/ghost_dive/effect.dart';
import 'package:grimoji/features/match/board/effects/line_clear/effect.dart';
import 'package:grimoji/features/match/board/effects/sparkle/effect.dart';
import 'package:grimoji/features/match/board/effects/wheel_roll/effect.dart';
import 'package:grimoji/features/match/constants.dart';

class VFXController {
  final sparkleManager = EffectManager<SparkleEffect>(
    lifetime: sparkleLifetime,
  );
  final lineClearManager = EffectManager<LineClearEffect>(
    lifetime: const Duration(milliseconds: 300),
  );
  final wheelRollManager = EffectManager<RollEffect>(
    lifetime: const Duration(milliseconds: 1200),
  );
  final ghostDiveManager = EffectManager<GhostDiveEffect>(
    lifetime: ghostDiveDuration,
  );

  bool _isDisposed = false;

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
  }

  void unbindState(LevelState state) {
    state.coordinator.onLineClear = null;
    state.coordinator.onWheelRoll = null;
    state.coordinator.onGhostDive = null;
  }

  void triggerSparkle(Offset localPosition) {
    if (!_isDisposed) {
      sparkleManager.trigger(SparkleEffect(position: localPosition));
    }
  }

  void dispose() {
    _isDisposed = true;
    sparkleManager.dispose();
    lineClearManager.dispose();
    wheelRollManager.dispose();
    ghostDiveManager.dispose();
  }
}
