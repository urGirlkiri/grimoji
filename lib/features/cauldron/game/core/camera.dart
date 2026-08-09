import 'dart:math' as math;

import 'package:flame/components.dart';

void fitCauldronCamera(
  CameraComponent camera,
  Vector2 viewportSize,
  Vector2 worldCauldronSize, {
  double padding = 0.90,
}) {
  camera.viewport.size = viewportSize;

  final zoomX = (viewportSize.x * padding) / worldCauldronSize.x;
  final zoomY = (viewportSize.y * padding) / worldCauldronSize.y;

  camera.viewfinder.zoom = math.min(zoomX, zoomY);
  camera.viewfinder.anchor = Anchor.center;
  camera.viewfinder.position = Vector2(0, 0);
}
