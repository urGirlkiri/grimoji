import 'package:flutter/material.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/level/state.dart';

abstract class PowerupHandler {
  Future<void> execute(
    BuildContext context,
    Powerup powerup,
    LevelState levelState,
  );
}
