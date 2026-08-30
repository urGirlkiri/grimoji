import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/effects/blood_drop/animation.dart';
import 'package:grimoji/features/match/board/effects/blood_drop/effect.dart';
import 'package:grimoji/features/match/constants.dart';

class BloodDropOverlay extends StatelessWidget {
  final ValueNotifier<List<BloodDropEffect>> notifier;
  final double tileWidth;
  final double tileHeight;

  const BloodDropOverlay({
    super.key,
    required this.notifier,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double stepX = tileWidth + tileSpacingGap;
    final double stepY = tileHeight + tileSpacingGap;

    return ValueListenableBuilder<List<BloodDropEffect>>(
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
              child: BloodDropAnimation(
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
