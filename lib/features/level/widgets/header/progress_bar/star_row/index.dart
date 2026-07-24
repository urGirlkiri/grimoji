import 'dart:math' as math;

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

    const starSize = 32.0;
    const halfSize = starSize / 2;
    final thresholds = data.crimson ? [0.5, 0.7, 1.0] : [0.33, 0.66, 1.0];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final maxLeft = math.max(0.0, width - starSize);

        return SizedBox(
          width: width,
          height: starSize,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              for (int i = 0; i < thresholds.length; i++)
                Positioned(
                  left: (thresholds[i] * width - halfSize).clamp(0.0, maxLeft),
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Star(
                      isActive: progress >= thresholds[i],
                      isCrimson: data.crimson,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
