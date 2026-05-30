import 'package:flutter/material.dart';
import 'package:grimoji/features/audio/sounds.dart';
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

  static const String _basePath = 'assets/icons/app/';
  static const String _iconExt = 'png';

  String get imagePath => '$_basePath$fileName.$_iconExt';

  @override
  State<AppIcon> createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 150),
    vsync: this,
  );

  late final Animation<double> _scaleAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enableSound && mounted) {
      context.readAudio.playSfx(SfxType.buttonTap);
    }
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget icon = GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_scaleAnimation.value * 0.1),
            child: Opacity(opacity: widget.isActive ? 1.0 : 0.4, child: child),
          );
        },
        child: Image.asset(
          widget.imagePath,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
        ),
      ),
    );

    if (widget.enableAnimation) {
      return BreathingWidget(
        duration: const Duration(milliseconds: 1200),
        minScale: 1.0,
        maxScale: 1.061,
        child: icon,
      );
    }
    return icon;
  }
}
