import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/level/widgets/overlays/level_complete.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class TargetFlightAnimator {
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
            context.readAudio.playSfx(SfxType.targetCollected);
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
                child: EmojiWidget.svg(path: emoji.svg, size: 50),
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
