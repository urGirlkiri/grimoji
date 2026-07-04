import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:grimoji/features/match/board/effects/sparkle/effect.dart';

class SparkleOverlay extends StatelessWidget {
  final ValueNotifier<List<SparkleEffect>> sparklesNotifier;

  const SparkleOverlay({super.key, required this.sparklesNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<SparkleEffect>>(
      valueListenable: sparklesNotifier,
      builder: (context, sparkles, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: sparkles.map((sparkle) {
            return Positioned(
              key: ValueKey(sparkle.id),
              left: sparkle.position.dx - 50,
              top: sparkle.position.dy - 50,
              child: RepaintBoundary(
                child: IgnorePointer(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Lottie.asset(
                      'assets/lottie/stars.json',
                      repeat: false,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
