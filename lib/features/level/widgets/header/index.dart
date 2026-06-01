import 'package:flutter/material.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/level/widgets/header/mascot.dart';
import 'package:grimoji/features/level/widgets/header/progress_bar.dart';
import 'package:grimoji/features/level/widgets/header/target_box.dart';
import 'package:grimoji/features/level/widgets/header/timer_box.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 230,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              color: context.palette.mist,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TimerBox(),
                  const SizedBox(width: 16),
                  TargetBox(),
                  const SizedBox(width: 16),
                  const Mascot(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Level ${context.watch<GameLevel>().number}',
                style: TextStyle(
                  color: context.palette.trueWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: ProgressBar()),
            ],
          ),
        ],
      ),
    );
  }
}
