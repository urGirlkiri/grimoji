import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final levelState = context.watch<LevelState>();
    final progress = levelState.progress;
    final hasTargetCombo = levelState.gameState.hasTargetCombo;
    final isPaused = levelState.isPaused;

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Container(
          width: double.infinity,
          height: 14,
          decoration: ShapeDecoration(
            color: context.palette.twilight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(60),
            ),
          ),
        ),
        AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutBack,
          widthFactor: progress.clamp(0.0, 1.0),
          child: AnimatedContainer(
            duration: isPaused
                ? Duration.zero
                : const Duration(milliseconds: 400),
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStar(isActive: progress >= 0.33),
            _buildStar(isActive: progress >= 0.66),
            _buildStar(isActive: progress >= 1.00),
          ],
        ),
      ],
    );
  }

  Widget _buildStar({required bool isActive}) {
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.8,
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/level/star.png"),
            ),
          ),
        ),
      ),
    );
  }
}
