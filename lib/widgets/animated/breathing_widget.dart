import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BreathingWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool enabled;
  
  final BoxShadow? beginShadow;
  final BoxShadow? endShadow;
  final BorderRadius? borderRadius;

  const BreathingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.minScale = 1.0,
    this.maxScale = 1.04,
    this.enabled = true,
    this.beginShadow,
    this.endShadow,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    var animation = child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: Offset(minScale, minScale),
          end: Offset(maxScale, maxScale),
          duration: duration,
          curve: Curves.easeInOutSine,
          alignment: Alignment.center,
        );

    if (beginShadow != null && endShadow != null) {
      animation = animation.boxShadow(
        begin: beginShadow,
        end: endShadow,
        borderRadius: borderRadius ?? BorderRadius.zero,
        duration: duration,
        curve: Curves.easeInOutSine,
      );
    }

    return animation;
  }
}