import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/cauldron/game/index.dart';

class EmojiBody extends BodyComponent<CauldronGame> {
  final Vector2 initialPosition;
  final GameEmoji emoji;
  final double radius;

  EmojiBody({
    required this.initialPosition,
    required this.emoji,
    this.radius = 0.5,
  });

  @override
  bool get renderBody => false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final svgInstance = await Svg.load(emoji.svg.replaceAll('assets/', ''));

    final svgComp = SvgComponent(
      svg: svgInstance,
      size: Vector2.all(radius * 2.2),
      anchor: Anchor.center,
    );

    add(svgComp);
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = radius;

    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.05,
      friction: 0.85,
      density: 1.0,
    );

    final bodyDef = BodyDef(type: BodyType.dynamic, position: initialPosition);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
