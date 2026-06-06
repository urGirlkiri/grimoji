import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:grimoji/features/cauldron/game/core/container/vertices.dart';
import 'package:grimoji/features/cauldron/game/index.dart';
import 'package:logging/logging.dart';

class CauldronBack extends BodyComponent<CauldronGame> {
  final Logger _logger = Logger("CauldronContainer");
  final Vector2 worldSize;

  @override
  final Vector2 position;

  CauldronBack({
    required this.worldSize,
    required this.position,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      SpriteComponent(
        sprite: await Sprite.load('cauldron/CauldronBack.png'),
        size: worldSize,
        anchor: Anchor.center,
      ),
    );

    priority = 0;
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: position,
    );

    final body = world.createBody(bodyDef);

    final shape = ChainShape()
      ..createChain(vertices);

    body.createFixture(
      FixtureDef(
        shape,
        friction: 0.9,
        restitution: 0.02,
      ),
    );

    return body;
  }

  @override
  void onHotReload() {
    super.onHotReload();
    
    world.destroyBody(body);
    _logger.info("Rebuilding Physics Body");
    body = createBody();
  }
} 