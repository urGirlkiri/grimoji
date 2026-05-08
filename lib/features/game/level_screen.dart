import 'package:flutter/material.dart';
import 'package:mojingo/features/game/logic/levels.dart';
import 'package:mojingo/features/game/widgets/game_board.dart';
import 'package:mojingo/features/game/widgets/header.dart';
import 'package:mojingo/features/game/widgets/power_ups.dart';
import 'package:mojingo/widgets/responsive_screen.dart';

class LevelScreen extends StatelessWidget {
  final GameLevel level;

  const LevelScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveScreen(
        topMessageArea: Header(level: level),
        squarishMainArea:  GameBoard(),
        rectangularMenuArea: PowerUps(),
        mobileBackgroundImage: const AssetImage('assets/images/level/game.png'),
        desktopBackgroundImage: const AssetImage(
          'assets/images/level/large_game.png',
        ),
      ),
    );
  }
}
