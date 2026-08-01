import 'dart:async';
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart' hide PointerMoveEvent;
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/cauldron/game/state.dart';
import 'package:grimoji/features/cauldron/game/core/container/front.dart';
import 'package:grimoji/features/cauldron/game/core/prediction_line.dart';
import 'package:grimoji/features/cauldron/game/core/container/index.dart';
import 'package:grimoji/features/cauldron/game/core/emoji_body.dart';
import 'package:grimoji/features/cauldron/game/core/overflow_sensor/index.dart';

class CauldronGame extends Forge2DGame
    with TapCallbacks, PointerMoveCallbacks, DragCallbacks {
  final ColorScheme colorScheme;
  final double globalScale;
  final BuildContext context;
  final CauldronState gameState;

  static final Vector2 worldCauldronSize = Vector2(10.5125, 9.573);

  static const double overflowY = -3.5;

  late final OverflowSensor _overflowSensor;
  late final PredictionLine predictionLine;

  static const double minDropX = -4.5;
  static const double maxDropX = 4.5;

  static const double dropSpawnY = -4.5;
  static const double cauldronBottomY = 3.5;
  static const bool showHalfLine = false;

  bool _canDrop = true;
  final math.Random _random = math.Random();

  final List<GameEmoji> _spawnableEmojis = [
    Emojis.smile,
    Emojis.fire,
    Emojis.pizza,
    Emojis.alien,
    Emojis.rocket,
    Emojis.poop,
    Emojis.heart,
  ];

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

    gameState.setNextEmoji(
      _spawnableEmojis[_random.nextInt(_spawnableEmojis.length)],
    );

    _overflowSensor = OverflowSensor(
      sensorPosition: Vector2(0, overflowY),
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

    camera.viewport.size = size;

    const padding = 0.90;

    final zoomX = (size.x * padding) / worldCauldronSize.x;
    final zoomY = (size.y * padding) / worldCauldronSize.y;
    camera.viewfinder.zoom = math.min(zoomX, zoomY);
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2(0, 0);
  }

  void _updateDropPosition(Vector2 screenPosition) {
    final worldPosition = camera.globalToLocal(screenPosition);
    final clampedX = worldPosition.x.clamp(minDropX, maxDropX);

    predictionLine.updateLine(
      Vector2(clampedX, dropSpawnY),
      Vector2(clampedX, cauldronBottomY + (showHalfLine ? 2.5 : 0)),
    );
  }

  void _dropEmoji() {
    if (!_canDrop || predictionLine.start == null || gameState.isGameOver) {
      return;
    }

    _canDrop = false;

    final dropX = predictionLine.start!.x;
    final emoji = gameState.nextEmoji;

    final emojiBody = EmojiBody(
      initialPosition: Vector2(dropX, dropSpawnY),
      emoji: emoji,
    );

    world.add(emojiBody);
    gameState.setNextEmoji(
      _spawnableEmojis[_random.nextInt(_spawnableEmojis.length)],
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      _canDrop = true;
    });
  }

  void reset() {
    final emojis = world.children.whereType<EmojiBody>().toList();
    for (final emoji in emojis) {
      emoji.removeFromParent();
    }

    _overflowSensor.reset();
    _canDrop = true;

    gameState.reset();
    gameState.setNextEmoji(
      _spawnableEmojis[_random.nextInt(_spawnableEmojis.length)],
    );

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
    _dropEmoji();
    super.onTapUp(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _dropEmoji();
    super.onDragEnd(event);
  }
}
