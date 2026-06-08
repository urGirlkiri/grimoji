import 'package:flutter/material.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/level/widgets/header/header_bar/index.dart';
import 'package:grimoji/features/level/widgets/header/progress_bar/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      height: 230,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderBar(),
          SizedBox(height: 24),
          Row(
            children: [
              _LevelText(),
              SizedBox(width: 12),
              Expanded(child: ProgressBar()),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelText extends StatelessWidget {
  const _LevelText();

  @override
  Widget build(BuildContext context) {
    final levelNumber = context.select<GameLevel, int>((level) => level.number);

    return Text(
      'Level $levelNumber',
      style: TextStyle(
        color: context.palette.trueWhite,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}