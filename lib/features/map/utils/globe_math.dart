import 'package:grimoji/features/map/models/projection_result.dart';

class GlobeMath {
  static const double _perspectiveDepth = 0.002;
  static const double _globeBend = 0.0004;

  static ProjectionResult project({
    required double worldX,
    required double worldZ,
    required double cameraZ,
    required double screenWidth,
    required double screenHeight,
  }) {
    final double relativeZ = worldZ - cameraZ;

    bool isBehindCamera = relativeZ < -200;

    if (isBehindCamera) {
      return ProjectionResult(isVisible: false, x: 0, y: 0, scale: 0, depth: relativeZ);
    }

    final double scale = 1.0 / (1.0 + (relativeZ * _perspectiveDepth));

    final double vanishingPoint = screenWidth / 2;
    final double screenX = vanishingPoint + (worldX * scale);

    final double linearY = relativeZ * 0.8;
    final double curveY = (relativeZ * relativeZ) * _globeBend;
    
    final double baseY = screenHeight - 150; 
    final double screenY = baseY - linearY + curveY;

    final bool isVisible = screenY < screenHeight + 200;

    return ProjectionResult(
      isVisible: isVisible,
      x: screenX,
      y: screenY,
      scale: scale.clamp(0.0, 1.0),
      depth: relativeZ, 
    );
  }
}
