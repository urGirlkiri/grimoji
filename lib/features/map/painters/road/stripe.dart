import 'package:flutter/material.dart'
    show
        CustomPainter,
        Color,
        Canvas,
        Size,
        Offset,
        Paint,
        PaintingStyle,
        StrokeCap;
import 'package:grimoji/app/palette.dart';
import 'package:grimoji/features/map/models/projection.dart';
import 'package:grimoji/features/map/utils/world_physics.dart';

class RoadStripePainter extends CustomPainter {
  final double cameraZ;
  final double maxZ;
  final double center;
  final double scale;

  RoadStripePainter({
    required this.cameraZ,
    required this.maxZ,
    required this.center,
    required this.scale,
  });

  static const double _baseRopeWidth = 9.0;
  static const double _stepSize = 16.0;
  static const double _tieSpacingWorld = 0.0;
  static final Color _ropeColor = palette.mist;
  static final Color _ropeTieColor = palette.voidBlack;

  @override
  void paint(Canvas canvas, Size size) {
    final double startZ = (cameraZ - 100).clamp(0.0, maxZ);
    final double endZ = (cameraZ + 1400).clamp(0.0, maxZ + 200);

    final List<Offset> points = [];
    final List<double> scales = [];
    final List<double> depths = [];
    final List<double> opacities = [];

    for (double z = startZ; z <= endZ; z += _stepSize) {
      final Projection proj = WorldPhysics.project(
        worldX: center,
        worldZ: z,
        cameraZ: cameraZ,
        screenWidth: size.width,
        screenHeight: size.height,
      );

      if (proj.isVisible) {
        points.add(Offset(proj.x, proj.y));
        scales.add(proj.scale);
        depths.add(z);
        opacities.add(proj.opacity);
      }
    }

    if (points.length < 2) return;

    final Paint ropePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i < points.length; i++) {
      ropePaint.strokeWidth = (_baseRopeWidth * scales[i] * scale).clamp(
        1.0,
        _baseRopeWidth * scale,
      );
      ropePaint.color = _ropeColor.withValues(alpha: opacities[i]);
      canvas.drawLine(points[i - 1], points[i], ropePaint);
    }

    final Paint tiePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i < points.length; i++) {
      if ((depths[i] % _tieSpacingWorld) > _stepSize) continue;

      final Offset a = points[i - 1];
      final Offset b = points[i];
      final Offset dir = b - a;
      final double len = dir.distance;
      if (len == 0) continue;

      final Offset normal = Offset(-dir.dy, dir.dx) / len;
      final double tieLen = 5.0 * scales[i] * scale;

      tiePaint.strokeWidth = (2.0 * scales[i] * scale).clamp(
        0.5,
        2.0 * scale,
      );
      tiePaint.color = _ropeTieColor.withValues(alpha: opacities[i]);
      canvas.drawLine(b - normal * tieLen, b + normal * tieLen, tiePaint);
    }
  }

  @override
  bool shouldRepaint(covariant RoadStripePainter oldDelegate) {
    return oldDelegate.cameraZ != cameraZ;
  }
}
