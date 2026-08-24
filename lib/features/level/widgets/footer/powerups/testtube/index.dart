import 'package:flutter/material.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/level/models/powerup_handler.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/testtube/analyzer/index.dart';
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

      final grid = levelState.coordinator.engine.grid;
      final analysis = await TestTubeAnalyzer.analyzeTarget(
        grid: grid,
        target: selected,
      );

      _log.info(
        'Best emoji: ${analysis.bestEmoji.visual}, match type: ${analysis.matchType}, size: ${analysis.matchSize}',
      );

      levelState.onPowerupImpact = () async {
        await levelState.coordinator.testTubeImpact(
          selected,
          analysis.bestEmoji,
        );
      };

      final animation = levelState.startPowerupAnimation();
      levelState.triggerTestTube(selected);

      await animation;
    } catch (e) {
      _log.info('Cancelled: $e');
      levelState.updatePowerupHoverTarget(null);
    }
  }
}
