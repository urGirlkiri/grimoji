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

    final shape = ChainShape()
      ..createLoop(vertices.sublist(0, vertices.length - 1));
    body.createFixture(FixtureDef(shape, friction: 1.0, restitution: 0.05));

    final floorWidth = CauldronGame.worldCauldronSize.x - 3.5;
    final floorTop = CauldronGame.cauldronBottomY - position.y;

    final floorShape = PolygonShape()
      ..setAsBox(floorWidth / 2, 0.5, Vector2(0, floorTop + 0.5), 0);

    body.createFixture(
      FixtureDef(floorShape, friction: 1.0, restitution: 0.05),
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
