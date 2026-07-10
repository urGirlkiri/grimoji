import 'package:flutter/material.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/level/models/powerup_handler.dart';
import 'package:grimoji/features/level/state.dart';

class PunchHandler implements PowerupHandler {
  @override
  Future<void> execute(
    BuildContext context,
    Powerup powerup,
    LevelState levelState,
  ) async {
    final selected = await levelState.awaitPowerupTile();

    if (levelState.gameState.isGameOver || levelState.gameState.isPaused) {
      return;
    }

    debugPrint('PunchHandler selected tile: ${selected.row}, ${selected.col}');

    await levelState.coordinator.punchTile(selected);
  }
}
