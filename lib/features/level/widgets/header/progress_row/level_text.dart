import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:provider/provider.dart';

class LevelText extends StatelessWidget {
  const LevelText({super.key});

  @override
  Widget build(BuildContext context) {
    final levelNumber = context.select<GameLevel, int>((level) => level.number);

    return Text(
      'Level $levelNumber',
      style: TextStyle(
        color: palette.trueWhite,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}
