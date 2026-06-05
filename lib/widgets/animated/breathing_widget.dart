import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BreathingWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool enabled;

  const BreathingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.minScale = 1.0,
    this.maxScale = 1.04,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return child.animate(
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      begin: Offset(minScale, minScale),
      end: Offset(maxScale, maxScale),
      duration: duration,
      curve: Curves.easeInOutSine,
      alignment: Alignment.center,
    );
  }
}

