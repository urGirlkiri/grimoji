import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/features/cauldron/game/core/out_of_bounds.dart';
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
  final Set<EmojiBody> _scoredInside = {};

  late final OverflowSensor _overflowSensor;
  late final EmojiSpawner _spawner;
  late final PredictionLine predictionLine;

  static final Vector2 worldCauldronSize = Vector2(10.5125, 9.573);
  static const double overflowPosition = -5.0;

  static const double minDropX = -4.5;
  static const double maxDropX = 4.5;

  static const double dropSpawnY = -4.5;
  static const double cauldronBottomY = 3.5;
  static const bool showHalfLine = false;
  
  static const int insideScore = 2;
  static const int outsideDecrease = 1;
  static const int outsidePenalty = 10;

  bool isAuto = false;
  bool _isHolding = false;
  double _autoDropTimer = 0.0;
  final double _autoDropInterval = 0.2;

  CauldronGame({
    required this.context,
    required this.colorScheme,
    required this.globalScale,
    required this.gameState,
  }) : super(gravity: Vector2(0, 30)) {
    debugMode = false;
  }


  void reset() {
    final emojis = world.children.whereType<EmojiBody>().toList();
    for (final emoji in emojis) {
      emoji.removeFromParent();
    }

    _scoredInside.clear();
    _overflowSensor.reset();
    _spawner.reset();

    gameState.reset();
    _spawner.rollNextEmoji();

    resumeEngine();
  }

  void fellOutside(EmojiBody emoji) {
    if (_scoredInside.contains(emoji)) {
      _scoredInside.remove(emoji);
      gameState.subtractScore(outsidePenalty);
    }
    gameState.subtractScore(outsideDecrease);
    
    emoji.removeFromParent();
  }

  void fellInside(EmojiBody emoji) {
    if (!_scoredInside.contains(emoji)) {
      _scoredInside.add(emoji);
      gameState.addScore(insideScore);
    }
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

    await world.add(OutOfBoundsSensor());
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    fitCauldronCamera(camera, size, worldCauldronSize);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isAuto && _isHolding) {
      _autoDropTimer += dt;
      if (_autoDropTimer >= _autoDropInterval) {
        _autoDropTimer = 0;
        if (predictionLine.start != null) {
          _spawner.spawn(Vector2(predictionLine.start!.x, dropSpawnY));
        }
      }
    }
  }

  void _updateDropPosition(Vector2 screenPosition) {
    final worldPosition = camera.globalToLocal(screenPosition);
    final clampedX = worldPosition.x.clamp(minDropX, maxDropX);

    predictionLine.updateLine(
      Vector2(clampedX, dropSpawnY),
      Vector2(clampedX, cauldronBottomY + (showHalfLine ? 2.5 : 0)),
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

  @override
  void onTapDown(TapDownEvent event) {
    _updateDropPosition(event.canvasPosition);
    _isHolding = isAuto;
    if (isAuto && predictionLine.start != null) {
      _autoDropTimer = 0;
      _spawner.spawn(Vector2(predictionLine.start!.x, dropSpawnY));
    }
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _updateDropPosition(event.canvasPosition);
    if (!isAuto && predictionLine.start != null) {
      _spawner.spawn(Vector2(predictionLine.start!.x, dropSpawnY));
    }
    _isHolding = false;
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isHolding = false;
    _autoDropTimer = 0;
    super.onTapCancel(event);
  }

  @override
  void onDragStart(DragStartEvent event) {
    _updateDropPosition(event.canvasPosition);
    _isHolding = isAuto;
    if (isAuto && predictionLine.start != null) {
      _autoDropTimer = 0;
      _spawner.spawn(Vector2(predictionLine.start!.x, dropSpawnY));
    }
    super.onDragStart(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (!isAuto && predictionLine.start != null) {
      _spawner.spawn(Vector2(predictionLine.start!.x, dropSpawnY));
    }
    _isHolding = false;
    _autoDropTimer = 0;
    super.onDragEnd(event);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    _isHolding = false;
    _autoDropTimer = 0;
    super.onDragCancel(event);
  }
}
