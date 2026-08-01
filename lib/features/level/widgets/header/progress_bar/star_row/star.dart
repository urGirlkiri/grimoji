import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/widgets/custom/star_icon.dart';

class Star extends StatelessWidget {
  const Star({super.key, required this.isActive, this.isCrimson = false});

  final bool isActive;
  final bool isCrimson;

  @override
  Widget build(BuildContext context) {
    final isFullyVisible = isActive || isCrimson;

    final targetOpacity = isFullyVisible ? 1.0 : 0.3;
    final targetScale = isFullyVisible ? 1.0 : 0.8;

    final Color targetColor;
    if (isCrimson) {
      targetColor = isActive
          ? palette.crimson
          : palette.moonlight;
    } else {
      targetColor = isActive ? palette.moonlight : palette.mist;
    }

    final key = ValueKey('flare_${isCrimson}_$isActive');

    return AnimatedScale(
      scale: targetScale,
      duration: 500.ms,
      curve: Curves.elasticOut,
      child: AnimatedOpacity(
        opacity: targetOpacity,
        duration: 300.ms,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isCrimson && isActive)
              StarIcon(size: 32, color: palette.crimson)
                  .animate(key: key)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(2.5, 2.5),
                    duration: 600.ms,
                    curve: Curves.easeOutCubic,
                  )
                  .fadeOut(duration: 600.ms, curve: Curves.easeOutCubic),

            TweenAnimationBuilder<Color?>(
              tween: ColorTween(begin: palette.mist, end: targetColor),
              duration: 400.ms,
              curve: Curves.easeInOut,
              builder: (context, color, _) => StarIcon(size: 32, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
