import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class BarFill extends StatelessWidget {
  const BarFill({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.select<LevelState, ({bool crimson, double progress})>(
      (s) => (
        crimson: s.isGoalComplete,
        progress: s.isGoalComplete ? s.crimsonProgress : s.progress,
      ),
    );

    final hasTargetCombo = context.select<LevelState, bool>(
      (s) => s.gameState.hasTargetCombo,
    );
    
    final isPaused = context.select<LevelState, bool>(
      (s) => s.gameState.isPaused,
    );
    
    final isCompleteOrWon = context.select<LevelState, bool>(
      (s) =>
          s.isGoalComplete ||
          (s.gameState.isGameOver && s.goalManager.calculateStars() >= 1),
    );
    
    final isHighlighted = hasTargetCombo || isCompleteOrWon;
    final isCrimson = data.crimson;

    double safe(double v) => v.isFinite ? v.clamp(0.0, 1.0) : 0.0;
    final normalProgress = safe(isCrimson ? 1.0 : data.progress);
    final crimsonProgress = safe(isCrimson ? data.progress : 0.0);

    final duration = isPaused ? Duration.zero : const Duration(milliseconds: 600);
    final baseColor = isHighlighted ? context.palette.moonlight : context.palette.mist;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            AnimatedContainer(
              duration: duration,
              curve: Curves.easeOut,
              width: normalProgress * maxWidth,
              height: 14,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.circular(60),
                boxShadow: (isHighlighted && !isCrimson && !isPaused)
                    ? [
                        BoxShadow(
                          color: baseColor.withValues(alpha: .8),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
            
            AnimatedContainer(
              duration: duration,
              curve: Curves.easeOut,
              width: crimsonProgress * maxWidth,
              height: 14,
              decoration: BoxDecoration(
                color: context.palette.crimson,
                borderRadius: BorderRadius.circular(60),
                boxShadow: (isCrimson && !isPaused)
                    ? [
                        BoxShadow(
                          color: context.palette.crimson.withValues(alpha: .8),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }
}