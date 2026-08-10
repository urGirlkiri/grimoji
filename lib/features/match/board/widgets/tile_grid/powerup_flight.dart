import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/audio/sounds/sfx.dart';
import 'package:grimoji/features/level/widgets/overlays/level_complete.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class PowerupFlightAnimator {
  static void launch({
    required BuildContext context,
    required Offset startOffset,
    required GlobalKey targetKey,
    required GameEmoji emoji,
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

    final Offset endOffset =
        targetBox.localToGlobal(Offset.zero) +
        Offset(targetBox.size.width / 2 - 20, targetBox.size.height / 2 - 20);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutBack,
          onEnd: () {
            entry.remove();
            context.readAudio.playSfx(Sfx.targetCollected);
            onComplete?.call();
          },
          builder: (context, value, child) {
            final double currentX =
                startOffset.dx + ((endOffset.dx - startOffset.dx) * value);
            final double currentY =
                startOffset.dy + ((endOffset.dy - startOffset.dy) * value);

            const double scale = 1.3;

            return Positioned(
              left: currentX,
              top: currentY,
              child: Transform.scale(
                scale: scale,
                child: EmojiWidget.svg(emoji: emoji, size: 40),
              ),
            );
          },
        );
      },
    );

    final levelComEntry = LevelComOverlay.currentEntry;

    if (levelComEntry != null) {
      Overlay.of(context).insert(entry, below: levelComEntry);
    } else {
      Overlay.of(context).insert(entry);
    }
  }
}
