













import 'package:flutter/material.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/level/models/powerup_handler.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:logging/logging.dart';

class PunchHandler implements PowerupHandler {
  static final _log = Logger('PunchHandler');

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

      final animationFuture = levelState.startPowerupAnimation();
      await animationFuture;

      await Future.delayed(const Duration(milliseconds: 300));

      await levelState.coordinator.punchTile(selected);
    } catch (e) {
      _log.info('Cancelled: $e');
      levelState.updatePowerupHoverTarget(null);
    }
  }
}
