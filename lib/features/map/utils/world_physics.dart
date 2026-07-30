import 'dart:math' as math;

import 'package:grimoji/features/map/models/projection.dart';

class WorldPhysics {

  static const double _perspectiveDepth = 0.0034;
  static const double _climbDepth = 8.0;
  static const double _fadeDepth = 300.0;

  static const double _worldHeight = 0.11;
  static const double _bottomOverflow = 50.0;

  static const double _bellyCurve = 0.011;
  static const double _lateralDepth = 1.1;

  static double horizonY(double screenHeight) =>
      screenHeight * _worldHeight;

  static double domeCurve(double screenHeight) =>
      screenHeight * _bellyCurve;

  static double domeOffset({
    required double screenX,
    required double screenWidth,
    required double screenHeight,
  }) {
    final double u = (screenX / screenWidth).clamp(0.0, 1.0);
    final double lateral = (_lateralDepth * u);
    return domeCurve(screenHeight) * lateral * lateral;
  }

  static Projection project({
    required double worldX,
    required double worldZ,
    required double cameraZ,
    required double screenWidth,
    required double screenHeight,
  }) {
    final double relativeZ = worldZ - cameraZ;

    if (relativeZ < -300) {
      return Projection(
        isVisible: false,
        x: 0,
        y: 0,
        scale: 0,
        depth: relativeZ,
        opacity: 0,
      );
    }

    final double scale = (1.0 / (1.0 + (relativeZ * _perspectiveDepth))).clamp(
      0.0,
      1.0,
    );

    final double vanishingPointX = (screenWidth / 2) - 10;
    final double screenX = vanishingPointX + (worldX * scale);

    // t: 0 right at the camera plane, approaches 1 as depth grows.
    final double t = (1.0 - scale).clamp(0.0, 1.0);
    final double easedT = 1.0 - math.pow(1.0 - t, _climbDepth).toDouble();

    final double nearY = screenHeight + _bottomOverflow;
    final double dome = domeOffset(
      screenX: screenX,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
    );
    
    final double localHorizonY = horizonY(screenHeight) + dome;
    final double screenY = nearY + (localHorizonY - nearY) * easedT;

    final double distanceFromHorizon = (screenY - localHorizonY).abs();
    final double opacity = (distanceFromHorizon / _fadeDepth).clamp(0.0, 1.0);

    final bool isVisible = opacity > 0.01;

    return Projection(
      isVisible: isVisible,
      x: screenX,
      y: screenY,
      scale: scale,
      depth: relativeZ,
      opacity: opacity,
    );
  }
}
