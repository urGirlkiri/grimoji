import 'dart:async';
import 'dart:math' as math; 
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:grimoji/app/palette.dart';
import 'core/container/index.dart';

final Vector2 worldCauldronSize = Vector2(10.9125, 9.93);
const cauldronScale = 18.0; 

class CauldronGame extends Forge2DGame with TapCallbacks {
  final ColorScheme colorScheme;
  final double globalScale;
  final BuildContext context;
  
  static final palette = Palette();

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

    await world.add(
      CauContainer(
        worldSize: worldCauldronSize, 
        position: Vector2(0, 0.5), 
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    
    camera.viewport.size = size;
    
    final shortestSide = math.min(size.x, size.y);
    camera.viewfinder.zoom = (shortestSide / cauldronScale) * globalScale;
    
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2(0, 0);
  }
}