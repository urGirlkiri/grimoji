import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/breathing_widget.dart';

class PillButton extends StatefulWidget {
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
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final effectiveTextColor = widget.textColor ?? palette.trueWhite;
    final effectiveBorderColor = widget.borderColor ?? palette.twilight;
    final effectiveBorderWidth = widget.borderWidth ?? 2;

    final effectivePadding =
        widget.padding ??
        (widget.fullWidth
            ? const EdgeInsets.symmetric(vertical: 14)
            : const EdgeInsets.symmetric(horizontal: 24, vertical: 12));

    final innerText = Text(
      widget.text,
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
      width: widget.fullWidth ? double.infinity : null,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(
          color: effectiveBorderColor,
          width: effectiveBorderWidth,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.color.withValues(alpha: 0.8),
            widget.color.withValues(alpha: 0.2),
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
      child: widget.fullWidth ? Center(child: innerText) : innerText,
    );

    final touchableButton = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        context.readAudio.playSfx(SfxType.buttonTap);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: buttonContainer,
      ),
    );

    return widget.enableAnimation
        ? BreathingWidget(
            duration: const Duration(milliseconds: 1200),
            maxScale: 1.04,
            child: touchableButton,
          )
        : touchableButton;
  }
}
