import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/utils/context_data.dart';

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
    if (_isPlaying) return;

    widget.onTap?.call();

    if (!context.readSettings.emojiAnimations.value) return;

    setState(() => _isPlaying = true);
    if (_controller.duration != null) {
      _controller.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPlaying) {
      return GestureDetector(
        onTap: _onTap,
        child: SvgPicture.asset(
          widget.emoji.svg,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
        ),
      );
    }

    return Lottie.asset(
      widget.emoji.lottie,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      controller: _controller,
      onLoaded: (composition) {
        _controller.duration = composition.duration;
        if (_isPlaying && !_controller.isAnimating) {
          _controller.forward(from: 0);
        }
      },
    );
  }
}
