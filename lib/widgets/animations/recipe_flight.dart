import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class RecipeFlightAnimator {
  static void launch({
    required OverlayState overlay,
    required Offset startOffset,
    required GlobalKey targetKey,
    required GameEmoji unlockedEmoji,
    VoidCallback? onComplete,
  }) {
    if (targetKey.currentContext == null) {
      onComplete?.call();
      return;
    }

    final RenderBox? targetBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetBox == null) {
      onComplete?.call();
      return;
    }

    final Offset endOffset = targetBox.localToGlobal(Offset.zero);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOutBack,
          onEnd: () {
            entry.remove();
            onComplete?.call();
          },
          builder: (context, value, child) {

            final double pauseProgress = (value < 0.083) ? 0.0 : ((value - 0.083) / 0.917).clamp(0.0, 1.0);
            final double pausedFlightProgress = Curves.easeInOut.transform(pauseProgress);
            final double currentX =
                startOffset.dx + ((endOffset.dx - startOffset.dx) * pausedFlightProgress);
            final double rawY =
                startOffset.dy + ((endOffset.dy - startOffset.dy) * pausedFlightProgress);
            final double arcOffset = sin(pausedFlightProgress * pi) * 80.0;
            final double currentY = rawY - arcOffset;

            final double scale = 1.25 + ((0.0001 - 1.25) * pauseProgress);
            final double spin = pauseProgress * 4 * pi;
            final double glowProgress = Curves.easeOut.transform((1.0 - pauseProgress).clamp(0.0, 1.0));
            final Color glowColor = Palette().magicCyan.withValues(alpha: 0.9 * glowProgress);
            final double glowBlur = 12 + (64 * glowProgress);
            final double glowSpread = 1 + (4 * glowProgress);

            return Positioned(
              left: currentX,
              top: currentY,
              child: Opacity(
                opacity: (1.0 - value).clamp(0.0, 1.0),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..scaleByVector3(Vector3(scale, scale, scale))
                    ..rotateZ(spin),
                  child: Container(
                    width: 120,
                    height: 180,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: glowColor,
                          blurRadius: glowBlur,
                          spreadRadius: glowSpread,
                        ),
                      ],
                    ),
                    child: Center(
                      child: EmojiWidget.svg(
                        path: unlockedEmoji.svg,
                        size: 56,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    overlay.insert(entry);
  }
}