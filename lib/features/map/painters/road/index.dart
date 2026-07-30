import 'dart:math' as math;

import 'package:flutter/material.dart'
    show CustomPainter, Color, Canvas, Size, Offset, Paint, Path;
import 'package:grimoji/app/palette.dart';
import 'package:grimoji/features/map/models/projection.dart';
import 'package:grimoji/features/map/utils/world_physics.dart';

class RoadPainter extends CustomPainter {
  final double cameraZ;
  final double maxZ;
  final double center;

  RoadPainter({
    required this.cameraZ,
    required this.maxZ,
    required this.center,
  });

  static const double _baseRoadHalfWidth = 80.0;
  static const double _stepSize = 0.0;
  static final Color _roadColor = palette.dusk;

  @override
  void paint(Canvas canvas, Size size) {
    final double startZ = (cameraZ - 100).clamp(0.0, maxZ);
    final double endZ = (cameraZ + 1400).clamp(0.0, maxZ + 200);

    final List<Offset> centerPoints = [];
    final List<double> scales = [];
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
        centerPoints.add(Offset(proj.x, proj.y));
        scales.add(proj.scale);
        opacities.add(proj.opacity);
      }
    }

    if (centerPoints.length < 2) return;

    final List<Offset> leftEdge = [];
    final List<Offset> rightEdge = [];

    for (int i = 0; i < centerPoints.length; i++) {
      final Offset prev = centerPoints[i == 0 ? i : i - 1];
      final Offset next =
          centerPoints[i == centerPoints.length - 1 ? i : i + 1];
      final Offset dir = next - prev;
      final double len = dir.distance;
      final Offset normal = len == 0
          ? const Offset(1, 0)
          : Offset(-dir.dy, dir.dx) / len;

      final double halfWidth = _baseRoadHalfWidth * scales[i];
      leftEdge.add(centerPoints[i] - normal * halfWidth);
      rightEdge.add(centerPoints[i] + normal * halfWidth);
    }

    final Paint segmentPaint = Paint()..color = _roadColor;

    for (int i = 1; i < centerPoints.length; i++) {
      final double segmentOpacity = math.min(opacities[i - 1], opacities[i]);
      if (segmentOpacity <= 0.01) continue;

      final Path segment = Path()
        ..moveTo(leftEdge[i - 1].dx, leftEdge[i - 1].dy)
        ..lineTo(leftEdge[i].dx, leftEdge[i].dy)
        ..lineTo(rightEdge[i].dx, rightEdge[i].dy)
        ..lineTo(rightEdge[i - 1].dx, rightEdge[i - 1].dy)
        ..close();

      // segmentPaint.color = _roadColor.withValues(alpha: segmentOpacity);
      segmentPaint.color = _roadColor;
      canvas.drawPath(segment, segmentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) {
    return oldDelegate.cameraZ != cameraZ;
  }
}
