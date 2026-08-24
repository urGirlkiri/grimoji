import 'package:flutter/material.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/level/models/powerup_handler.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:logging/logging.dart';

class TestTubeHandler implements PowerupHandler {
  static final _log = Logger('TestTubeHandler');

  @override
  Future<void> execute(
    BuildContext context,
    Powerup powerup,
    LevelState levelState,
  ) async {
    try {
      final selected = await levelState.awaitPowerupTile(powerup);

      if (levelState.gameState.isGameOver || levelState.gameState.isPaused) {
        return;
      }

      _log.info('Selected tile: ${selected.row}, ${selected.col}');

      // levelState.onPowerupImpact = () {
        levelState.coordinator.testTubeImpact(selected);
      // };

      // final animation = levelState.startPowerupAnimation();
      // levelState.triggerTestTube(selected);

      // await animation;

      // await levelState.coordinator.bloodTile(selected);
    } catch (e) {
      _log.info('Cancelled: $e');
      levelState.updatePowerupHoverTarget(null);
    }
  }
}
