import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class AbductedEmojiWidget extends StatefulWidget {
  final GameEmoji emoji;
  final double startX;
  final double startY;
  final double endX;
  final double endY;
  final double size;
  final VoidCallback? onComplete;

  const AbductedEmojiWidget({
    super.key,
    required this.emoji,
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.size,
    this.onComplete,
  });

  @override
  State<AbductedEmojiWidget> createState() => _AbductedEmojiWidgetState();
}

class _AbductedEmojiWidgetState extends State<AbductedEmojiWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _launched = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: ufoAbductDuration);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onComplete?.call();
    });
    Future.delayed(ufoBeamDuration, () {
      if (mounted) {
        setState(() => _launched = true);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_launched) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final eased = Curves.easeIn.transform(t);

        final x = widget.startX + ((widget.endX - widget.startX) * eased);
        final y = widget.startY + ((widget.endY - widget.startY) * eased);
        final scale = 1.0 - (0.85 * eased);
        final opacity = t < 0.7 ? 1.0 : (1.0 - ((t - 0.7) / 0.3));

        return Positioned(
          left: x - (widget.size / 2),
          top: y - (widget.size / 2),
          width: widget.size,
          height: widget.size,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: scale,
              child: EmojiWidget.svg(emoji: widget.emoji, size: widget.size),
            ),
          ),
        );
      },
    );
  }
}
