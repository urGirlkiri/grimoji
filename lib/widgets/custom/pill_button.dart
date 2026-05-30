import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/sounds.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/breathing_widget.dart';
import 'package:provider/provider.dart';

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

class _PillButtonState extends State<PillButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapController = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

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

    Widget innerText = Text(
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

    Widget buttonContainer = Container(
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

    Widget touchableButton = GestureDetector(
      onTapDown: (_) => _tapController.forward(),
      onTapUp: (_) => _tapController.reverse(),
      onTapCancel: () => _tapController.reverse(),
      onTap: () {
        context.read<AudioController>().playSfx(SfxType.buttonTap);
        widget.onTap();
      },
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.95).animate(
          CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
        ),
        child: buttonContainer,
      ),
    );

    if (widget.enableAnimation) {
      return BreathingWidget(child: touchableButton);
    }

    return touchableButton;
  }
}
