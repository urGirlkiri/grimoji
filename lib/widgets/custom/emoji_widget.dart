import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:drop_shadow/drop_shadow.dart' as ds;
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/config/emojis/index.dart';

/// A reusable widget that displays emoji animations.
/// Supports Lottie (.json), SVG (.svg), and plain text emojis.
class EmojiWidget extends StatelessWidget {
  final String assetPath;
  final double size;
  final double blurRadius;
  final Offset shadowOffset;
  final Color shadowColor;
  final bool useDropShadow;
  final bool? animate;
  final bool? repeat;
  final String? semanticLabel;
  final bool selected;
  final AnimationController? controller;
  final void Function(LottieComposition)? onLoaded;

  const EmojiWidget({
    super.key,
    required this.assetPath,
    this.size = 120,
    this.blurRadius = 8,
    this.shadowOffset = const Offset(0, 6),
    this.shadowColor = const Color(0x660E0E12),
    this.useDropShadow = false,
    this.animate,
    this.repeat,
    this.semanticLabel,
    this.selected = false,
    this.controller,
    this.onLoaded,
  });

  /// Named constructor for Lottie animations
  factory EmojiWidget.lottie({
    Key? key,
    required GameEmoji emoji,
    double size = 120,
    double blurRadius = 8,
    Offset shadowOffset = const Offset(0, 6),
    Color shadowColor = const Color(0x660E0E12),
    bool useDropShadow = false,
    bool? animate,
    bool? repeat,
    bool selected = false,
    AnimationController? controller,
    void Function(LottieComposition)? onLoaded,
  }) {
    return EmojiWidget(
      key: key,
      assetPath: emoji.lottie,
      size: size,
      blurRadius: blurRadius,
      shadowOffset: shadowOffset,
      shadowColor: shadowColor,
      useDropShadow: useDropShadow,
      animate: animate,
      repeat: repeat,
      semanticLabel: emoji.visual,
      selected: selected,
      controller: controller,
      onLoaded: onLoaded,
    );
  }

  /// Named constructor for SVG images
  factory EmojiWidget.svg({
    Key? key,
    required GameEmoji emoji,
    double size = 120,
    double blurRadius = 8,
    Offset shadowOffset = const Offset(0, 6),
    Color shadowColor = const Color(0x660E0E12),
    bool useDropShadow = false,
    bool selected = false,
  }) {
    return EmojiWidget(
      key: key,
      assetPath: emoji.svg,
      size: size,
      blurRadius: blurRadius,
      shadowOffset: shadowOffset,
      shadowColor: shadowColor,
      useDropShadow: useDropShadow,
      semanticLabel: emoji.visual,
      selected: selected,
    );
  }

  /// Named constructor for text emojis
  factory EmojiWidget.text({
    Key? key,
    required GameEmoji emoji,
    double size = 80,
    bool selected = false,
  }) {
    return EmojiWidget(
      key: key,
      assetPath: emoji.visual,
      size: size,
      blurRadius: 0,
      shadowOffset: Offset.zero,
      shadowColor: Colors.transparent,
      useDropShadow: false,
      semanticLabel: emoji.visual,
      selected: selected,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsOn = context.readSettings.emojiAnimations.value;
    final shouldAnimate = animate ?? settingsOn;
    final shouldRepeat = repeat ?? shouldAnimate;

    Widget child;
    if (assetPath.endsWith('.json')) {
      child = RepaintBoundary(
        child: Lottie.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          animate: shouldAnimate,
          repeat: shouldRepeat,
          controller: controller,
          onLoaded: onLoaded,
          frameRate: const FrameRate(30),
        ),
      );
      if (useDropShadow) {
        child = ds.DropShadow(
          blurRadius: blurRadius,
          offset: shadowOffset,
          color: shadowColor,
          child: child,
        );
      }
    } else if (assetPath.endsWith('.svg')) {
      child = SvgPicture.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
      if (useDropShadow) {
        child = ds.DropShadow(
          blurRadius: blurRadius,
          offset: shadowOffset,
          color: shadowColor,
          child: child,
        );
      }
    } else {
      child = Text(assetPath, style: TextStyle(fontSize: size));
    }

    if (semanticLabel != null) {
      child = Semantics(label: semanticLabel, selected: selected, child: child);
    }
    return child;
  }
}
