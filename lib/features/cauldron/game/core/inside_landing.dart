import 'dart:developer';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:grimoji/features/cauldron/game/index.dart';
import 'package:grimoji/features/cauldron/game/core/emoji_spawner/emoji.dart';

class InsideLandingSensor extends BodyComponent<CauldronGame> with ContactCallbacks {
  
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(0, 3.2), 
      type: BodyType.static,
    );
    final body = world.createBody(bodyDef);
    
    final shape = EdgeShape()..set(Vector2(-3.8, -6.38), Vector2(3.8, -6.38));
    
    body.createFixture(FixtureDef(shape, isSensor: true, userData: this));
    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is EmojiBody) {
      log('hit bottom of the cauldron!');
      game.fellInside(other);
    }
    super.beginContact(other, contact);
  }
}