import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/breathing_widget.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';

class PillButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;
  final VoidCallback onTap;
  final bool fullWidth;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? borderColor;
  final double? borderWidth;
  final bool enableAnimation;

  const PillButton({
    super.key,
    required this.text,
    required this.color,
    required this.onTap,
    this.textColor,
    this.fullWidth = true,
    this.padding,
    this.borderRadius = 40,
    this.borderColor,
    this.borderWidth,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final effectiveTextColor = textColor ?? palette.trueWhite;
    final effectiveBorderColor = borderColor ?? palette.twilight;
    final effectiveBorderWidth = borderWidth ?? 2;

    final effectivePadding =
        padding ??
        (fullWidth
            ? const EdgeInsets.symmetric(vertical: 14)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 12));

    final innerText = Text(
      text,
      style: GoogleFonts.eagleLake(
        color: effectiveTextColor,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: palette.voidBlack.withValues(alpha: 0.5),
            offset: const Offset(1, 2),
            blurRadius: 2,
          ),
        ],
      ),
    );

    final buttonContainer = Container(
      width: fullWidth ? double.infinity : null,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: effectiveBorderWidth,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.2),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.voidBlack.withValues(alpha: 0.6),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
          BoxShadow(
            color: palette.twilight.withValues(alpha: 0.2),
            offset: const Offset(0, -2),
            blurRadius: 2,
          ),
        ],
      ),
      child: fullWidth ? Center(child: innerText) : innerText,
    );

    final touchableButton = AnimatedButton(
      onTap: onTap,
      pressedScale: 0.95,
      child: buttonContainer,
    );

    return enableAnimation
        ? BreathingWidget(
            duration: const Duration(milliseconds: 1200),
            maxScale: 1.04,
            child: touchableButton,
          )
        : touchableButton;
  }
}
