import 'package:flutter/material.dart';
import 'package:grimoji/app/palette.dart';
import 'package:grimoji/features/map/utils/world_physics.dart';

const palette = Palette();

class GroundPainter extends CustomPainter {
  static const double _horizonBow = 52.0;
  static const double _rimShadowDepth = 40.0;
  
  static final Color _bottomColor = palette.twilight;
  static final Color _topColor = palette.midnight;
  static final Color _rimShadowColor = palette.voidBlack;

  @override
  void paint(Canvas canvas, Size size) {
    final double horizonY = WorldPhysics.horizonY(size.height);
    final double crestY = horizonY - _horizonBow;

    final Path groundPath = Path()
      ..moveTo(0, horizonY + _horizonBow)
      ..quadraticBezierTo(
        size.width / 2,
        crestY,
        size.width,
        horizonY + _horizonBow,
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
            Rect.fromLTWH(0, crestY, size.width, size.height - crestY),
          );

    canvas.drawPath(groundPath, groundPaint);

    final Path rimShadowPath = Path()
      ..moveTo(0, horizonY + _horizonBow)
      ..quadraticBezierTo(
        size.width / 2,
        crestY,
        size.width,
        horizonY + _horizonBow,
      )
      ..quadraticBezierTo(
        size.width / 2,
        crestY + _rimShadowDepth,
        0,
        horizonY + _horizonBow,
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
            Rect.fromLTWH(0, crestY, size.width, _rimShadowDepth + _horizonBow),
          );

    canvas.drawPath(rimShadowPath, rimShadowPaint);
  }

  @override
  bool shouldRepaint(covariant GroundPainter oldDelegate) => false;
}
