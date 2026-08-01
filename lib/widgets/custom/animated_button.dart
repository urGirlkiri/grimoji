import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/features/audio/sounds/sfx.dart';
import 'package:grimoji/utils/context_data.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final FutureOr<void> Function()? onTap;
  final bool enableSound;
  final double pressedScale;

  const AnimatedButton({
    super.key,
    required this.child,
    this.onTap,
    this.enableSound = true,
    this.pressedScale = 0.9,
  });

  @override
  State createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  bool _isPressed = false;
  bool _isProcessing = false;

  Future<void> _handleTap() async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      if (widget.enableSound && mounted) {
        context.readAudio.playSfx(Sfx.buttonTap);
      }
      await widget.onTap?.call();
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _isPressed ? widget.pressedScale : 1.0,
        duration: 150.ms,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
