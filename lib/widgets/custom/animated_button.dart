import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/utils/context_data.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
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

  void _handleTap() {
    if (widget.enableSound && mounted) {
      context.readAudio.playSfx(SfxType.buttonTap);
    }
    widget.onTap?.call();
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
