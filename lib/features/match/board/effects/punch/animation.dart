import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/match/board/effects/punch/effect.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class PunchGlove extends StatefulWidget {
  final PunchEffect effect;
  final double tileWidth;
  final double tileHeight;

  const PunchGlove({
    super.key,
    required this.effect,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  State<PunchGlove> createState() => _PunchGloveState();
}

class _PunchGloveState extends State<PunchGlove>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepX = widget.tileWidth + tileSpacingGap;
    final stepY = widget.tileHeight + tileSpacingGap;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;

        final startX = widget.effect.target.col * stepX;
        final startY = widget.effect.target.row * stepY - widget.tileHeight * 2;

        final endX = widget.effect.target.col * stepX;
        final endY = widget.effect.target.row * stepY;

        final x = startX + (endX - startX) * t;
        final y = startY + (endY - startY) * t;

        final angle = t * 3.14;

        final scale = 1.0 + (t > 0.8 ? (t - 0.8) * 2.5 : 0.0);

        final opacity = t < 0.8 ? 1.0 : 1.0 - (t - 0.8) / 0.2;

        return Positioned(
          left: x,
          top: y,
          width: widget.tileWidth,
          height: widget.tileHeight,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: angle,
              child: Transform.scale(
                scale: scale,
                child: EmojiWidget.svg(
                  path: Emojis.boxingGlove.svg,
                  size: widget.tileWidth * 1.2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
