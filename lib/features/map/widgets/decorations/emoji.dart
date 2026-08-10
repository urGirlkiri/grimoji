import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:lottie/lottie.dart';

import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class InteractableEmoji extends StatefulWidget {
  final GameEmoji emoji;
  final double size;
  final VoidCallback? onTap;

  const InteractableEmoji({
    super.key,
    required this.emoji,
    required this.size,
    this.onTap,
  });

  @override
  State<InteractableEmoji> createState() => _InteractableEmojiState();
}

class _InteractableEmojiState extends State<InteractableEmoji>
    with SingleTickerProviderStateMixin {
  final Logger _logger = Logger("InteractableEmoji");
  late final AnimationController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener(_onStatusChanged);
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatusChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _isPlaying = false);
      _controller.reset();
    }
  }

  void _onTap() {
    _logger.info("Tapped");
    if (_isPlaying) return;
    _logger.info("Playing");

    widget.onTap?.call();

    if (!context.readSettings.emojiAnimations.value) return;

    setState(() => _isPlaying = true);
    if (_controller.duration != null) {
      _controller.forward(from: 0);
    }
  }

  void _onLoaded(LottieComposition composition) {
    _controller.duration = composition.duration;
    if (_isPlaying && !_controller.isAnimating) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPlaying) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: EmojiWidget.svg(emoji: widget.emoji, size: widget.size),
      );
    }

    return EmojiWidget.lottie(
      emoji: widget.emoji,
      size: widget.size,
      animate: true,
      repeat: false,
      controller: _controller,
      onLoaded: _onLoaded,
    );
  }
}
