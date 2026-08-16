import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_svg/flame_svg.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/cauldron/game/core/emoji_spawner/emoji.dart';
import 'package:grimoji/features/cauldron/game/state.dart';

class EmojiSpawner extends Component with HasGameReference<Forge2DGame> {
  final CauldronState gameState;

  bool _canDrop = true;
  final math.Random _random = math.Random();

  final List<GameEmoji> _spawnableEmojis = [
    Emojis.smile,
    Emojis.fire,
    Emojis.pizza,
    Emojis.alien,
    Emojis.rocket,
    Emojis.poop,
    Emojis.heart,
  ];

  final Map<GameEmoji, Svg> _svgCache = {};

  EmojiSpawner({required this.gameState});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    for (final emoji in _spawnableEmojis) {
      final path = emoji.svg.replaceAll('assets/', '');
      _svgCache[emoji] = await game.loadSvg(path);
    }
  }

  void rollNextEmoji() {
    gameState.setNextEmoji(
      _spawnableEmojis[_random.nextInt(_spawnableEmojis.length)],
    );
  }

  void spawn(Vector2 position) {
    if (!_canDrop || gameState.isGameOver) {
      return;
    }

    _canDrop = false;

    final emoji = gameState.nextEmoji;
    game.world.add(
      EmojiBody(initialPosition: position, emoji: emoji, svg: _svgCache[emoji]),
    );

    rollNextEmoji();
    _canDrop = true;
  }

  void reset() {
    _canDrop = true;
  }
}
