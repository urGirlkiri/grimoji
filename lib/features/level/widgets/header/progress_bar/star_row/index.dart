import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/header/progress_bar/star_row/star.dart';
import 'package:provider/provider.dart';

class StarRow extends StatelessWidget {
  const StarRow({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.select<LevelState, double>((s) => s.progress);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Star(isActive: progress >= 0.33),
        Star(isActive: progress >= 0.66),
        Star(isActive: progress >= 1.00),
      ],
    );
  }
}