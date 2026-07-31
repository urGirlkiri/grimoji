import 'package:flutter/material.dart';
import 'package:grimoji/app/palette.dart';
import 'package:grimoji/features/map/utils/world_physics.dart';

const palette = Palette();

class GroundPainter extends CustomPainter {
  static final Color _bottomColor = palette.twilight;
  static final Color _topColor = palette.midnight;
  static final Color _rimShadowColor = palette.voidBlack;

  GroundPainter({super.repaint});

  @override
  void paint(Canvas canvas, Size size) {
    final double horizonY = WorldPhysics.horizonY(size.height);
    final double horizonCurve = size.height * 0.0523;
    final double rimShadowDepth = size.height * 0.0402;
    final double horizonPeak = horizonY - horizonCurve;

    final Path groundPath = Path()
      ..moveTo(0, horizonY + horizonCurve)
      ..quadraticBezierTo(
        size.width / 2,
        horizonPeak,
        size.width,
        horizonY + horizonCurve,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final Paint groundPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_topColor, _bottomColor],
          ).createShader(
            Rect.fromLTWH(0, horizonPeak, size.width, size.height - horizonPeak),
          );

    canvas.drawPath(groundPath, groundPaint);

    final Path rimShadowPath = Path()
      ..moveTo(0, horizonY + horizonCurve)
      ..quadraticBezierTo(
        size.width / 2,
        horizonPeak,
        size.width,
        horizonY + horizonCurve,
      )
      ..quadraticBezierTo(
        size.width / 2,
        horizonPeak + rimShadowDepth,
        0,
        horizonY + horizonCurve,
      )
      ..close();

    final Paint rimShadowPaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _rimShadowColor.withValues(alpha: 0.55),
              _rimShadowColor.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromLTWH(0, horizonPeak, size.width, rimShadowDepth + horizonCurve),
          );

    canvas.drawPath(rimShadowPath, rimShadowPaint);
  }

  @override
  bool shouldRepaint(covariant GroundPainter oldDelegate) => false;
}
