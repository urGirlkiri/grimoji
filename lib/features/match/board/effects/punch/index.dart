import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/effects/punch/effect.dart';
import 'package:grimoji/features/match/board/effects/punch/animation.dart';

class PunchOverlay extends StatelessWidget {
  final ValueNotifier<List<PunchEffect>> notifier;
  final double tileWidth;
  final double tileHeight;

  const PunchOverlay({
    super.key,
    required this.notifier,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<PunchEffect>>(
      valueListenable: notifier,
      builder: (context, effects, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: effects.map((effect) {
            return PunchGlove(
              key: ValueKey(effect.id),
              effect: effect,
              tileWidth: tileWidth,
              tileHeight: tileHeight,
            );
          }).toList(),
        );
      },
    );
  }
}
