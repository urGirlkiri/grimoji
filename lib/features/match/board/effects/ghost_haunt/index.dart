import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/effects/ghost_dive/effect.dart';
import 'package:grimoji/features/match/board/effects/ghost_haunt/animation.dart';
import 'package:grimoji/features/match/constants.dart';

class GhostHauntOverlay extends StatelessWidget {
  final ValueNotifier<List<GhostDiveEffect>> notifier;
  final double tileWidth;
  final double tileHeight;

  const GhostHauntOverlay({
    super.key,
    required this.notifier,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<GhostDiveEffect>>(
      valueListenable: notifier,
      builder: (context, effects, _) {
        final double stepX = tileWidth + tileSpacingGap;
        final double stepY = tileHeight + tileSpacingGap;

        return Stack(
          clipBehavior: Clip.none,
          children: effects.map((effect) {
            return Positioned(
              key: ValueKey(effect.id),
              left: effect.origin.col * stepX,
              top: effect.origin.row * stepY,
              width: tileWidth,
              height: tileHeight,
              child: GhostHaunter(
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
