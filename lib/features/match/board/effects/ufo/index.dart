import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/effects/ufo/animation/index.dart';
import 'package:grimoji/features/match/board/effects/ufo/effect.dart';

class UFOOverlay extends StatelessWidget {
  final ValueNotifier<List<UFOEffect>> notifier;
  final double tileWidth;
  final double tileHeight;

  const UFOOverlay({
    super.key,
    required this.notifier,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<UFOEffect>>(
      valueListenable: notifier,
      builder: (context, effects, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: effects.map((effect) {
            return Positioned.fill(
              key: ValueKey(effect.id),
              child: UFOAnimation(
                effect: effect,
                tileWidth: tileWidth,
                tileHeight: tileHeight,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
