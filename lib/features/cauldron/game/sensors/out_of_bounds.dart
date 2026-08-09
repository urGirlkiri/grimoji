import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:grimoji/features/cauldron/game/index.dart';
import 'package:grimoji/features/cauldron/game/core/emoji_spawner/emoji.dart';

class OutOfBoundsSensor extends BodyComponent<CauldronGame>
    with ContactCallbacks {
  static const double startXCoord = -300;
  static const double startYCoord = -8;

  static const double endXCoord = -startXCoord;
  static const double endYCoord = startYCoord;

  @override
  Body createBody() {
    final bodyDef = BodyDef(position: Vector2(0, 15.0), type: BodyType.static);
    final body = world.createBody(bodyDef);

    final shape = EdgeShape()
      ..set(Vector2(startXCoord, startYCoord), Vector2(endXCoord, endYCoord));

    body.createFixture(FixtureDef(shape, isSensor: true, userData: this));
    return body;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is EmojiBody) {
      game.fellOutside(other);
    }
    super.beginContact(other, contact);
  }

}
