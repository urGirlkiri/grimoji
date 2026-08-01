import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/app/theme/palette.dart';
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
  final double? fontSize;
  final bool enableAnimation;
  final Widget? leading;

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
    this.fontSize,
    this.enableAnimation = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    

    final effectiveTextColor = textColor ?? palette.trueWhite;
    final effectiveBorderColor = borderColor ?? palette.twilight;
    final effectiveBorderWidth = borderWidth ?? 2;

    final innerText = Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.eagleLake(
        color: effectiveTextColor,
        fontWeight: FontWeight.bold,
        fontSize: fontSize,
        decoration: TextDecoration.none,
        shadows: [
          Shadow(
            color: palette.voidBlack.withValues(alpha: 0.5),
            offset: const Offset(1, 2),
            blurRadius: 2,
          ),
        ],
      ),
    );

    return BreathingWidget(
      enabled: enableAnimation,
      duration: const Duration(milliseconds: 1200),
      maxScale: 1.04,
      child: AnimatedButton(
        onTap: onTap,
        pressedScale: 0.95,
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: 24,
                vertical: fullWidth ? 14 : 12,
              ),
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
          child: fullWidth
              ? Center(
                  child: leading != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            leading!,
                            const SizedBox(width: 8),
                            Flexible(child: innerText),
                          ],
                        )
                      : innerText,
                )
              : leading != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    leading!,
                    const SizedBox(width: 8),
                    Flexible(child: innerText),
                  ],
                )
              : innerText,
        ),
      ),
    );
  }
}
