import 'dart:developer';

import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:grimoji/features/cauldron/game/index.dart';
import 'package:grimoji/features/cauldron/game/core/emoji_spawner/emoji.dart';

class OutOfBoundsSensor extends BodyComponent<CauldronGame> with ContactCallbacks {
  
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(0, 15.0),
      type: BodyType.static,
    );
    final body = world.createBody(bodyDef);
    
    final shape = EdgeShape()..set(Vector2(-30, 0), Vector2(30, 0));
    
    body.createFixture(FixtureDef(shape, isSensor: true));
    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is EmojiBody) {
      log('fell');
      game.fellOutside(other);
    }
    super.beginContact(other, contact);
  }
}