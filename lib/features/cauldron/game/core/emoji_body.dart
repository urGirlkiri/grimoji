import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/cauldron/game/index.dart';

class EmojiBody extends BodyComponent<CauldronGame> {
  final Vector2 initialPosition;
  final GameEmoji emoji;

  final double scaleFactor;

  EmojiBody({
    required this.initialPosition,
    required this.emoji,
    this.scaleFactor = 1.0,
  });

  @override
  bool get renderBody => false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final svgInstance = await Svg.load(emoji.svg.replaceAll('assets/', ''));
    const double vsize = 1.0;

    final svgComp = SvgComponent(
      svg: svgInstance,
      size: Vector2.all(vsize * scaleFactor * 1.1),
      anchor: Anchor.center,
    );

    add(svgComp);
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
      linearDamping: 0.2,
      angularDamping: 1.5,
      bullet: true,
    );

    final body = world.createBody(bodyDef);

    final List<Vector2> vertices = emoji.physicsVertices
        .map(
          (vertex) => Vector2(vertex.x * scaleFactor, vertex.y * scaleFactor),
        )
        .toList();

    if (vertices.length >= 3 && vertices.length <= 8) {
      final polygonShape = PolygonShape()..set(vertices);

      final fixtureDef = FixtureDef(
        polygonShape,
        density: 1.5,
        friction: 0.75,
        restitution: 0.02,
      );

      body.createFixture(fixtureDef);
    } else {
      final fallbackShape = CircleShape()..radius = 0.5 * scaleFactor;
      body.createFixture(
        FixtureDef(
          fallbackShape,
          density: 1.0,
          friction: 0.5,
          restitution: 0.05,
        ),
      );
    }

    return body;
  }
}
