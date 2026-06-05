import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/widgets/animated/breathing_widget.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';

class AppIcon extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BreathingWidget(
      enabled: enableAnimation,
      duration: 1200.ms,
      maxScale: 1.061,
      child: AnimatedButton(
      onTap: onTap,
      enableSound: enableSound,
      child: AnimatedOpacity(
        duration: 150.ms,
        opacity: isActive ? 1.0 : 0.4,
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    ),
    );
  }
}