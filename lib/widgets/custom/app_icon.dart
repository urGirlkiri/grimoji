import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/breathing_widget.dart';

class AppIcon extends StatefulWidget {
  final String fileName;
  final double size;
  final VoidCallback? onTap;
  final bool isActive;
  final bool enableSound;
  final bool enableAnimation;

  const AppIcon({
    super.key,
    required this.fileName,
    this.size = 45,
    this.onTap,
    this.isActive = true,
    this.enableSound = true,
    this.enableAnimation = true,
  });

  String get imagePath => 'assets/icons/app/$fileName.png';

  @override
  State<AppIcon> createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> {
  bool _isPressed = false;

  void _handleTap() {
    if (widget.enableSound && mounted) {
      context.readAudio.playSfx(SfxType.buttonTap);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final icon = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: _handleTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: 150.ms,
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          duration: 150.ms,
          opacity: widget.isActive ? 1.0 : 0.4,
          child: Image.asset(
            widget.imagePath,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );

    return widget.enableAnimation
        ? BreathingWidget(
            duration: 1200.ms,
            maxScale: 1.061,
            child: icon,
          )
        : icon;
  }
}