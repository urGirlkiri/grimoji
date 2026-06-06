import 'dart:async';
import 'dart:math' as math; 
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
// 1. Only hide PointerMoveEvent, as that is the only true name collision
import 'package:flutter/material.dart' hide PointerMoveEvent;
import 'package:grimoji/app/palette.dart';
import 'package:grimoji/features/cauldron/game/core/prediction_line.dart';
import 'core/container/index.dart';

final Vector2 worldCauldronSize = Vector2(10.9125, 9.93);

class CauldronGame extends Forge2DGame with TapCallbacks, PointerMoveCallbacks, DragCallbacks {
  final ColorScheme colorScheme;
  final double globalScale;
  final BuildContext context;
  
  static final palette = Palette();

  late final PredictionLine predictionLine;

  final double minDropX = -4.5; 
  final double maxDropX = 4.5;
  
  final double dropSpawnY = -4.5; 
  final double cauldronBottomY = 3.5; 
  final bool halfShowLine = false;

  CauldronGame({
    required this.context,
    required this.colorScheme,
    required this.globalScale,
  }) : super(gravity: Vector2(0, 30)) {
    debugMode = true; 
  }

  @override
  Color backgroundColor() {
    return palette.midnight;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    predictionLine = PredictionLine();

    await world.addAll([
      CauContainer(
        worldSize: worldCauldronSize, 
        position: Vector2(0, 0.5), 
      ),
      predictionLine,
    ]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    camera.viewport.size = size;
    
    const padding = 0.90; 

    final zoomX = (size.x * padding) / worldCauldronSize.x;
    final zoomY = (size.y * padding) / worldCauldronSize.y;

    final baseZoom = math.min(zoomX, zoomY);

    camera.viewfinder.zoom = baseZoom;
    
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2(0, 0);
  }

  void _updateDropPosition(Vector2 screenPosition) {
    final worldPosition = camera.globalToLocal(screenPosition);
    final clampedX = worldPosition.x.clamp(minDropX, maxDropX);

    predictionLine.updateLine(
      Vector2(clampedX, dropSpawnY),
      Vector2(clampedX, cauldronBottomY  + (halfShowLine ? 2.5 : 0)),
    );
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    _updateDropPosition(event.canvasPosition);
    super.onPointerMove(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _updateDropPosition(event.canvasEndPosition);
    super.onDragUpdate(event);
  }
}