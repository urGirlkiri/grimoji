import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:grimoji/features/cauldron/game/core/emoji_body.dart';
import 'package:grimoji/features/cauldron/game/core/overflow_sensor/contact.dart';

class OverflowSensor extends BodyComponent<Forge2DGame> {
  final Vector2 size;
  final Vector2 sensorPosition;
  final Color lineColor;
  final VoidCallback onGameOver;

  final Set<EmojiBody> overlappingEmojis = {};

  static const double overflowWarningTime = 0.2;
  static const double overflowTriggerTime = 2.0;
  double _overflowTimer = 0.0;

  OverflowSensor({
    required this.size,
    required this.sensorPosition,
    required this.lineColor,
    required this.onGameOver,
  }) : super(paint: Paint()..color = lineColor.withValues(alpha: 0.0));

  @override
  Body createBody() {
    final shape = PolygonShape()..setAsBoxXY(size.x / 2, size.y / 2);

    final fixtureDef = FixtureDef(shape, isSensor: true);

    final bodyDef = BodyDef(position: sensorPosition, type: BodyType.static);

    final body = world.createBody(bodyDef)..createFixture(fixtureDef);
    body.userData = OverflowContactCallback(this);
    return body;
  }

  @override
  void update(double dt) {
    super.update(dt);

    bool isOverflowing = false;
    for (final emoji in overlappingEmojis) {
      if (emoji.body.linearVelocity.length < 1.0) {
        isOverflowing = true;
        break;
      }
    }

    if (isOverflowing) {
      _overflowTimer += dt;
      if (_overflowTimer >= overflowWarningTime) {
        paint.color = lineColor.withValues(alpha: 0.6);
      }
      if (_overflowTimer >= overflowTriggerTime) {
        onGameOver();
      }
    } else {
      if (_overflowTimer > 0) {
        _overflowTimer -= dt * 2;
        if (_overflowTimer < 0) _overflowTimer = 0;
      }
      paint.color = lineColor.withValues(alpha: 0.0);
    }
  }

  void addEmoji(EmojiBody emoji) => overlappingEmojis.add(emoji);

  void removeEmoji(EmojiBody emoji) => overlappingEmojis.remove(emoji);

  void reset() {
    overlappingEmojis.clear();
    _overflowTimer = 0.0;
    paint.color = lineColor.withValues(alpha: 0.0);
  }
}
