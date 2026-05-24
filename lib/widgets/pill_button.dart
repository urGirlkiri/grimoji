import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/sounds.dart';
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
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<Palette>(context);

    final effectiveTextColor = widget.textColor ?? palette.trueWhite;
    final effectiveBorderColor = widget.borderColor ?? palette.twilight;
    final effectiveBorderWidth = widget.borderWidth ?? 2;
    final effectivePadding = widget.padding ??
        (widget.fullWidth
            ? const EdgeInsets.symmetric(vertical: 14)
            : null);

    Widget button;

    if (widget.fullWidth) {
      button = GestureDetector(
        onTap: () {
          context.read<AudioController>().playSfx(SfxType.buttonTap);
          widget.onTap();
        },
        child: Container(
          width: double.infinity,
          padding: effectivePadding,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: effectiveBorderColor, width: effectiveBorderWidth),
            boxShadow: [
              BoxShadow(
                color: palette.voidBlack.withValues(alpha: 0.4),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
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
            ),
          ),
        ),
      );
    } else {
      button = FilledButton(
        onPressed: () {
          context.read<AudioController>().playSfx(SfxType.buttonTap);
          widget.onTap();
        },
        style: FilledButton.styleFrom(
          backgroundColor: widget.color,
          foregroundColor: effectiveTextColor,
          padding: effectivePadding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            side: BorderSide(color: effectiveBorderColor, width: effectiveBorderWidth),
          ),
        ),
        child: Text(
          widget.text,
          style: GoogleFonts.eagleLake(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (widget.enableAnimation) {
      button = MouseRegion(
        onEnter: (event) => _controller.repeat(),
        onExit: (event) => _controller.stop(canceled: false),
        child: RotationTransition(
          turns: _controller.drive(const _SineTween(0.005)),
          child: button,
        ),
      );
    }

    return button;
  }
}

class _SineTween extends Animatable<double> {
  final double maxExtent;

  const _SineTween(this.maxExtent);

  @override
  double transform(double t) => sin(t * 2 * pi) * maxExtent;
}
