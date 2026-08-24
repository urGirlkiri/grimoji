import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/effects/test_tube/effect.dart';
import 'package:grimoji/features/match/constants.dart';

class TestTubeOverlay extends StatelessWidget {
  final ValueNotifier<List<TestTubeEffect>> notifier;
  final double tileWidth;
  final double tileHeight;

  const TestTubeOverlay({
    super.key,
    required this.notifier,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double stepX = tileWidth + tileSpacingGap;
    final double stepY = tileHeight + tileSpacingGap;

    return ValueListenableBuilder<List<TestTubeEffect>>(
      valueListenable: notifier,
      builder: (context, effects, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: effects.map((effect) {
            return Positioned(
              key: ValueKey(effect.id),
              left: effect.coord.col * stepX,
              top: effect.coord.row * stepY,
              width: tileWidth,
              height: tileHeight,
              child: const SizedBox.shrink()
            );
          }).toList(),
        );
      },
    );
  }
}
