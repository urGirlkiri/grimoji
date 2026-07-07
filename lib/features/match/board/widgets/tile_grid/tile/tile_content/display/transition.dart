import 'package:flutter/material.dart';

class TileTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final bool isTransmuting;
  final bool isShuffling;

  const TileTransition({super.key, 
    required this.child,
    required this.animation,
    required this.isTransmuting,
    required this.isShuffling,
  });

  @override
  Widget build(BuildContext context) {
    Widget transition = FadeTransition(
      opacity: animation,
      child: ScaleTransition(scale: animation, child: child),
    );

    if (isTransmuting) {
      return RotationTransition(
        turns: Tween<double>(begin: -0.5, end: 0.0).animate(animation),
        child: transition,
      );
    }

    if (isShuffling) {
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut)),
        child: transition,
      );
    }

    return transition;
  }
}
