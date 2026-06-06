import 'package:flame/components.dart';

class CauldronFront extends SpriteComponent {
  CauldronFront({
    required Vector2 worldSize,
    required Vector2 worldPosition,
  }) : super(
          size: worldSize,
          position: worldPosition,
          anchor: Anchor.center,
          priority: 1000,
        );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('cauldron/CauldronFront.png');
  }
}