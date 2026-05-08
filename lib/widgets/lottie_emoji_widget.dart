import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart' hide DropShadow;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:drop_shadow/drop_shadow.dart';

/// A reusable widget that displays emoji animations.
/// Supports Lottie (.json), SVG (.svg), and plain text emojis.
class LottieEmojiWidget extends StatelessWidget {
  final String assetPath;
  final double size;
  final double blurRadius;
  final Offset shadowOffset;
  final Color shadowColor;

  const LottieEmojiWidget({
    super.key,
    required this.assetPath,
    this.size = 120,
    this.blurRadius = 8,
    this.shadowOffset = const Offset(0, 6),
    this.shadowColor = const Color(0x660E0E12),
  });

  /// Named constructor for Lottie animations
  const LottieEmojiWidget.lottie({
    Key? key,
    required String path,
    double size = 120,
    double blurRadius = 8,
    Offset shadowOffset = const Offset(0, 6),
    Color shadowColor = const Color(0x660E0E12),
  }) : this(
          key: key,
          assetPath: path,
          size: size,
          blurRadius: blurRadius,
          shadowOffset: shadowOffset,
          shadowColor: shadowColor,
        );

  /// Named constructor for SVG images
  const LottieEmojiWidget.svg({
    Key? key,
    required String path,
    double size = 120,
    double blurRadius = 8,
    Offset shadowOffset = const Offset(0, 6),
    Color shadowColor = const Color(0x660E0E12),
  }) : this(
          key: key,
          assetPath: path,
          size: size,
          blurRadius: blurRadius,
          shadowOffset: shadowOffset,
          shadowColor: shadowColor,
        );

  /// Named constructor for text emojis
  const LottieEmojiWidget.text({
    Key? key,
    required String emoji,
    double size = 80,
  }) : this(
          key: key,
          assetPath: emoji,
          size: size,
          blurRadius: 0,
          shadowOffset: Offset.zero,
          shadowColor: Colors.transparent,
        );

  @override
  Widget build(BuildContext context) {
    if (assetPath.endsWith('.json')) {
      return DropShadow(
        blurRadius: blurRadius,
        offset: shadowOffset,
        color: shadowColor,
        child: Lottie.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      );
    } else if (assetPath.endsWith('.svg')) {
      return DropShadow(
        blurRadius: blurRadius,
        offset: shadowOffset,
        color: shadowColor,
        child: SvgPicture.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return Text(
        assetPath,
        style: TextStyle(fontSize: size),
      );
    }
  }
}
