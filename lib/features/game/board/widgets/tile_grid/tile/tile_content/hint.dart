import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/features/game/board/models/coordinate.dart';
import 'package:grimoji/utils/context_data.dart';

class HintNudge extends StatelessWidget {
  final bool isHinting;
  final TileCoordinate current;
  final TileCoordinate? partner;
  final double tileWidth;
  final double tileHeight;
  final Widget child;

  const HintNudge({
    super.key,
    required this.isHinting,
    required this.current,
    this.partner,
    required this.tileWidth,
    required this.tileHeight,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isHinting || partner == null) return child;

    final palette = context.palette;
    final double dx = (partner!.col - current.col).toDouble();
    final double dy = (partner!.row - current.row).toDouble();

    return child
        .animate(
          onPlay: (controller) => controller.repeat(),
        )
        .custom(
          duration: 1200.ms,
          builder: (context, value, child) {
            final double progress = sin(value * pi);

            final double moveX = dx * (tileWidth + tileSpacingGap) * 0.4 * progress;
            final double moveY = dy * (tileHeight + tileSpacingGap) * 0.4 * progress;

            return Transform.translate(
              offset: Offset(moveX, moveY),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: palette.trueWhite.withValues(alpha: progress * 0.7),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
        );
  }
}