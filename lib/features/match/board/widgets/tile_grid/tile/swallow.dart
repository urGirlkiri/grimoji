import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class SwallowEffect extends StatelessWidget {
  final Widget child;
  final double size;
  final bool isSwallowing;

  const SwallowEffect({
    super.key,
    required this.child,
    required this.size,
    required this.isSwallowing,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSwallowing) {
      return child;
    }

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Center(
            child: EmojiWidget.svg(path: Emojis.hole.svg, size: size * 1.4)
                .animate()
                .scale(
                  begin: Offset.zero,
                  end: const Offset(1.1, 1.1),
                  duration: 150.ms,
                  curve: Curves.easeOutBack,
                )
                .then()
                .shake(hz: 8, duration: 200.ms, curve: Curves.linear)
                .rotate(
                  begin: 0,
                  end: -6,
                  duration: 450.ms,
                  curve: Curves.linear,
                )
                .then()
                .scale(
                  end: Offset.zero,
                  duration: 150.ms,
                  curve: Curves.easeInBack,
                ),
          ),
        ),
        child
            .animate()
            .rotate(
              begin: 0,
              end: 4,
              duration: 450.ms,
              curve: Curves.easeInOutQuint,
            )
            .scale(
              begin: const Offset(1, 1),
              end: Offset.zero,
              duration: 450.ms,
              curve: Curves.easeInOutQuint,
            )
            .blurXY(begin: 0, end: 8, duration: 450.ms)
            .fade(begin: 1, end: 0, duration: 450.ms),
      ],
    );
  }
}
