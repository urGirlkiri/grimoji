import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/header/progress_bar/star_row/star.dart';
import 'package:provider/provider.dart';

class StarRow extends StatelessWidget {
  const StarRow({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.select<LevelState, ({bool crimson, double progress})>(
      (s) => (
        crimson: s.isGoalComplete,
        progress: s.isGoalComplete ? s.crimsonProgress : s.progress,
      ),
    );

    final progress = data.progress.isFinite
        ? data.progress.clamp(0.0, 1.0)
        : 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Star(
          isActive: progress >= 0.33,
          isCrimson: data.crimson,
        ),
        Star(
          isActive: progress >= 0.66,
          isCrimson: data.crimson,
        ),
        Star(
          isActive: progress >= 1.00,
          isCrimson: data.crimson,
        ),
      ],
    );
  }
}