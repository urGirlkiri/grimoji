import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class BarFill extends StatelessWidget {
  const BarFill({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.select<LevelState, double>((s) => s.progress);
    final hasTargetCombo = context.select<LevelState, bool>(
      (s) => s.gameState.hasTargetCombo,
    );
    final isPaused = context.select<LevelState, bool>(
      (s) => s.gameState.isPaused,
    );

    return AnimatedFractionallySizedBox(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      widthFactor: progress.clamp(0.0, 1.0),
      child: AnimatedContainer(
        duration: isPaused ? Duration.zero : const Duration(milliseconds: 400),
        height: 14,
        decoration: ShapeDecoration(
          color: hasTargetCombo
              ? context.palette.moonlight
              : context.palette.mist,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          shadows: hasTargetCombo && !isPaused
              ? [
                  BoxShadow(
                    color: context.palette.moonlight.withValues(alpha: .8),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
      ),
    );
  }
}
