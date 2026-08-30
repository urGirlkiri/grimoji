import 'package:flutter/material.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/level/models/powerup_handler.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:logging/logging.dart';

class UFOHandler implements PowerupHandler {
  static final _log = Logger('UFOHandler');

  @override
  Future<void> execute(
    BuildContext context,
    Powerup powerup,
    LevelState levelState,
  ) async {
    try {

      if (levelState.gameState.isGameOver || levelState.gameState.isPaused) {
        return;
      }

      // final grid = levelState.coordinator.engine.grid;
      // final analysis = await UFOAnalyzer.analyzeTarget(
      //   grid: grid,
      // );

      levelState.onPowerupImpact = () async {
        // await levelState.coordinator.testTubeImpact(
        //   analysis.bestEmoji,
        // );
      };

      final animation = levelState.startPowerupAnimation();
      levelState.triggerUFO();

      await animation;
    } catch (e) {
      _log.info('Cancelled: $e');
      levelState.updatePowerupHoverTarget(null);
    }
  }
}
