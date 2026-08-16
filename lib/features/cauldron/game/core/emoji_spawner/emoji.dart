import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/cauldron/game/index.dart';

class EmojiBody extends BodyComponent<CauldronGame> {
  static const double vsize = 1.0;

  final double scaleFactor;
  final Vector2 initialPosition;
  final GameEmoji emoji;
  final Svg? svg;

  double _bulletTimer = 0;
  static const double _bulletDisableAfter = 1.0;

  EmojiBody({
    required this.initialPosition,
    required this.emoji,
    this.scaleFactor = 1.0,
    this.svg,
  });

  @override
  bool get renderBody => false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final svgInstance =
        svg ?? await Svg.load(emoji.svg.replaceAll('assets/', ''));

    final svgComp = SvgComponent(
      svg: svgInstance,
      size: Vector2.all(vsize * scaleFactor * 1.1),
      anchor: Anchor.center,
    );

    add(svgComp);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (body.isBullet) {
      _bulletTimer += dt;
      if (_bulletTimer >= _bulletDisableAfter) {
        body.isBullet = false;
      }
    }
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
      linearDamping: 0.8,
      angularDamping: 8,
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
        density: 0.9,
        friction: 1.0,
        restitution: 0.02,
      );

      body.createFixture(fixtureDef);
    } else {
      final fallbackShape = CircleShape()..radius = 0.5 * scaleFactor;
      body.createFixture(
        FixtureDef(
          fallbackShape,
          density: 0.9,
          friction: 1.0,
          restitution: 0.02,
        ),
      );
    }

    body.userData = this;
    return body;
  }
}
