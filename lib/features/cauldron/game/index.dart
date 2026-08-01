import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/features/cauldron/game/state.dart';
import 'package:grimoji/features/cauldron/game/utils/camera.dart';
import 'package:grimoji/features/cauldron/game/core/container/front.dart';
import 'package:grimoji/features/cauldron/game/core/emoji_spawner/index.dart';
import 'package:grimoji/features/cauldron/game/core/prediction_line.dart';
import 'package:grimoji/features/cauldron/game/core/container/index.dart';
import 'package:grimoji/features/cauldron/game/core/emoji_spawner/emoji.dart';
import 'package:grimoji/features/cauldron/game/core/overflow_sensor/index.dart';

class CauldronGame extends Forge2DGame
    with TapCallbacks, PointerMoveCallbacks, DragCallbacks {
  final ColorScheme colorScheme;
  final double globalScale;
  final BuildContext context;
  final CauldronState gameState;

  static final Vector2 worldCauldronSize = Vector2(10.5125, 9.573);

  static const double overflowPosition = -4.5;

  late final OverflowSensor _overflowSensor;
  late final EmojiSpawner _spawner;
  late final PredictionLine predictionLine;

  static const double minDropX = -4.5;
  static const double maxDropX = 4.5;

  static const double dropSpawnY = -4.5;
  static const double cauldronBottomY = 3.5;
  static const bool showHalfLine = false;

  CauldronGame({
    required this.context,
    required this.colorScheme,
    required this.globalScale,
    required this.gameState,
  }) : super(gravity: Vector2(0, 30)) {
    debugMode = false;
  }

  @override
  Color backgroundColor() {
    return Colors.transparent;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    predictionLine = PredictionLine();

    await world.add(
      CauldronBack(worldSize: worldCauldronSize, position: Vector2(0, 0.5)),
    );

    await world.add(predictionLine);

    _spawner = EmojiSpawner(gameState: gameState);
    await world.add(_spawner);
    _spawner.rollNextEmoji();

    _overflowSensor = OverflowSensor(
      sensorPosition: Vector2(0, overflowPosition),
      size: Vector2(worldCauldronSize.x - 3, 0.1),
      lineColor: palette.crimson,
      onGameOver: () {
        gameState.setGameOver();
        pauseEngine();
      },
    );
    await world.add(_overflowSensor);

    await world.add(
      CauldronFront(
        worldSize: worldCauldronSize,
        worldPosition: Vector2(0, 0.5),
      ),
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    fitCauldronCamera(camera, size, worldCauldronSize);
  }

  void _updateDropPosition(Vector2 screenPosition) {
    final worldPosition = camera.globalToLocal(screenPosition);
    final clampedX = worldPosition.x.clamp(minDropX, maxDropX);

    predictionLine.updateLine(
      Vector2(clampedX, dropSpawnY),
      Vector2(clampedX, cauldronBottomY + (showHalfLine ? 2.5 : 0)),
    );
  }

  void reset() {
    final emojis = world.children.whereType<EmojiBody>().toList();
    for (final emoji in emojis) {
      emoji.removeFromParent();
    }

    _overflowSensor.reset();
    _spawner.reset();

    gameState.reset();
    _spawner.rollNextEmoji();

    resumeEngine();
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

  @override
  void onTapUp(TapUpEvent event) {
    _updateDropPosition(event.canvasPosition);
    if (predictionLine.start != null) {
      _spawner.spawn(Vector2(predictionLine.start!.x, dropSpawnY));
    }
    super.onTapUp(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (predictionLine.start != null) {
      _spawner.spawn(Vector2(predictionLine.start!.x, dropSpawnY));
    }
    super.onDragEnd(event);
  }
}
