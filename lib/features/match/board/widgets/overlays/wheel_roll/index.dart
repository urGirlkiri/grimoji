import 'package:flutter/material.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/match/board/effects/roll.dart';
import 'package:grimoji/features/match/board/widgets/overlays/wheel_roll/roller.dart';

class WheelRollOverlay extends StatelessWidget {
  final ValueNotifier<List<RollEffect>> notifier;
  final double tileWidth;
  final double tileHeight;

  const WheelRollOverlay({
    super.key,
    required this.notifier,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<RollEffect>>(
      valueListenable: notifier,
      builder: (context, effects, _) {
        final double stepX = tileWidth + tileSpacingGap;
        final double stepY = tileHeight + tileSpacingGap;

        return Stack(
          clipBehavior: Clip.none,
          children: effects.map((effect) {
            return Positioned(
              key: ValueKey(effect.id),
              left: effect.startCol * stepX,
              top: effect.startRow * stepY,
              width: tileWidth,
              height: tileHeight,
              child: WheelRoller(
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
