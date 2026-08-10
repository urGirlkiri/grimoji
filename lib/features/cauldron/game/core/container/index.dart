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

  CauldronBack({required this.worldSize, required this.position})
    : super(renderBody: false);

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
    final bodyDef = BodyDef(type: BodyType.static, position: position);

    final body = world.createBody(bodyDef);

    final shape = ChainShape()..createChain(vertices);
    body.createFixture(FixtureDef(shape, friction: 1.0, restitution: 0.0));

    final floorWidth = CauldronGame.worldCauldronSize.x - 3;
    final floorTop = CauldronGame.cauldronBottomY - position.y;

    final floorShape = PolygonShape()
      ..set([
        Vector2(-floorWidth / 2, floorTop),
        Vector2(floorWidth / 2, floorTop),
        Vector2(floorWidth / 2, floorTop + 0.1),
        Vector2(-floorWidth / 2, floorTop + 0.1),
      ]);

    body.createFixture(FixtureDef(floorShape, friction: 1.0, restitution: 0.0));

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
