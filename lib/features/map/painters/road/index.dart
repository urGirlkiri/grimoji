import 'package:flutter/material.dart'
    show
        BlendMode,
        CustomPainter,
        Color,
        Canvas,
        Size,
        Offset,
        Paint,
        Path,
        Rect,
        Alignment,
        LinearGradient;
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
  static const double _stepSize = 16.0;
  static final Color _roadColor = palette.dusk;

  @override
  void paint(Canvas canvas, Size size) {
    final double startZ = (cameraZ - 100).clamp(0.0, maxZ);
    final double endZ = (cameraZ + 1400).clamp(0.0, maxZ + 200);

    final List<Offset> centerPoints = [];
    final List<double> scales = [];

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

    final Path roadPath = Path()..moveTo(leftEdge.first.dx, leftEdge.first.dy);
    for (final point in leftEdge.skip(1)) {
      roadPath.lineTo(point.dx, point.dy);
    }
    for (final point in rightEdge.reversed) {
      roadPath.lineTo(point.dx, point.dy);
    }
    roadPath.close();

    final Rect bounds = roadPath.getBounds();

    canvas.saveLayer(bounds, Paint());
    canvas.drawPath(roadPath, Paint()..color = _roadColor);

    final Paint fadeMask = Paint()
      ..blendMode = BlendMode.dstIn
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x00FFFFFF), Color(0xFFFFFFFF)],
        stops: [0.0, 0.6],
      ).createShader(bounds);
    canvas.drawRect(bounds, fadeMask);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) {
    return oldDelegate.cameraZ != cameraZ;
  }
}
