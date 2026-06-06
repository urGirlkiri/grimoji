import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:grimoji/features/cauldron/game/core/container/vertices.dart';
import 'package:grimoji/features/cauldron/game/index.dart';
import 'package:logging/logging.dart';

class CauContainer extends BodyComponent<CauldronGame> {
  CauContainer({required this.worldSize, required this.position});
  final Logger _logger = Logger("CauldronContainer");
  final Vector2 worldSize;

  @override
  final Vector2 position;


  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final sprite = await Sprite.load('cauldron/Cauldron.png');
    
    final comp = SpriteComponent(
      sprite: sprite,
      size: worldSize,
      anchor: Anchor.center,
    );

    add(comp);
  }

  @override
  Body createBody() {
    _logger.info('Creating pysics body');
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: position,
    );

    final body = world.createBody(bodyDef);
    final shape = ChainShape();

    shape.createChain(vertices);

    final fixtureDef = FixtureDef(
      shape,
      friction: 0.9,
      restitution: 0.02,
    );

    body.createFixture(fixtureDef);
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