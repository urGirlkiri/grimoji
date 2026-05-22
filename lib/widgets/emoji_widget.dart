import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:drop_shadow/drop_shadow.dart' as ds;

/// A reusable widget that displays emoji animations.
/// Supports Lottie (.json), SVG (.svg), and plain text emojis.
class EmojiWidget extends StatelessWidget {
  final String assetPath;
  final double size;
  final double blurRadius;
  final Offset shadowOffset;
  final Color shadowColor;
  final bool useDropShadow;

  const EmojiWidget({
    super.key,
    required this.assetPath,
    this.size = 120,
    this.blurRadius = 8,
    this.shadowOffset = const Offset(0, 6),
    this.shadowColor = const Color(0x660E0E12),
    this.useDropShadow = false,
  });

  /// Named constructor for Lottie animations
  const EmojiWidget.lottie({
    Key? key,
    required String path,
    double size = 120,
    double blurRadius = 8,
    Offset shadowOffset = const Offset(0, 6),
    Color shadowColor = const Color(0x660E0E12),
    bool useDropShadow = false,
  }) : this(
          key: key,
          assetPath: path,
          size: size,
          blurRadius: blurRadius,
          shadowOffset: shadowOffset,
          shadowColor: shadowColor,
          useDropShadow: useDropShadow,
        );

  /// Named constructor for SVG images
  const EmojiWidget.svg({
    Key? key,
    required String path,
    double size = 120,
    double blurRadius = 8,
    Offset shadowOffset = const Offset(0, 6),
    Color shadowColor = const Color(0x660E0E12),
    bool useDropShadow = false,
  }) : this(
          key: key,
          assetPath: path,
          size: size,
          blurRadius: blurRadius,
          shadowOffset: shadowOffset,
          shadowColor: shadowColor,
          useDropShadow: useDropShadow,
        );

  /// Named constructor for text emojis
  const EmojiWidget.text({
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
          useDropShadow: false,
        );

  @override
  Widget build(BuildContext context) {
    if (assetPath.endsWith('.json')) {
      final child = RepaintBoundary(
        child: Lottie.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          animate: true,
          repeat: true,
          frameRate: FrameRate(30),
        ),
      );
      if (useDropShadow) {
        return ds.DropShadow(
          blurRadius: blurRadius,
          offset: shadowOffset,
          color: shadowColor,
          child: child,
        );
      }
      return child;
    } else if (assetPath.endsWith('.svg')) {
      final child = SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
      if (useDropShadow) {
        return ds.DropShadow(
          blurRadius: blurRadius,
          offset: shadowOffset,
          color: shadowColor,
          child: child,
        );
      }
      return child;
    } else {
      return Text(
        assetPath,
        style: TextStyle(fontSize: size),
      );
    }
  }
}
