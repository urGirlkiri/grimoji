import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/board/models/roll.dart';

class WheelRoller extends StatefulWidget {
  final RollEffect effect;
  final double tileWidth;
  final double tileHeight;

  const WheelRoller({
    super.key,
    required this.effect,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  State<WheelRoller> createState() => _WheelRollerState();
}

class _WheelRollerState extends State<WheelRoller>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late final double _tileWidth;
  late final double _tileHeight;
  late final double _stepX;
  late final double _stepY;
  late final double _totalAngle;
  late final double _sign;

  @override
  void initState() {
    super.initState();

    _tileWidth = widget.tileWidth;
    _tileHeight = widget.tileHeight;

    _stepX = _tileWidth + tileSpacingGap;
    _stepY = _tileHeight + tileSpacingGap;

    _sign = widget.effect.isWrapping ? 1.0 : -1.0;

    final double totalDistance = widget.effect.isHorizontal
        ? _stepX * 3
        : _stepY * 3;

    final double radius = _tileWidth / 2;

    _totalAngle = (totalDistance / radius) * _sign;

    _controller = AnimationController(
      vsync: this,
      duration: wheelSpinTotalDuration,
    )..forward();
  }

  @override
  void didUpdateWidget(WheelRoller oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;
        final double dx = widget.effect.isHorizontal
            ? _sign * _stepX * 3 * t
            : 0;

        final double dy = widget.effect.isHorizontal
            ? 0
            : _sign * _stepY * 3 * t;

        final double angle = _totalAngle * t;

        final double opacity = t < 0.8 ? 1.0 : 1.0 - (t - 0.8) / 0.2;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: angle,
              child: SvgPicture.asset(
                Emojis.wheel.svg,
                width: _tileWidth * wheelVisualScaleFactor,
                height: _tileHeight * wheelVisualScaleFactor,
              ),
            ),
          ),
        );
      },
    );
  }
}
