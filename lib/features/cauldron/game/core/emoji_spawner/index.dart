import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
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

  EmojiSpawner({required this.gameState});

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
      EmojiBody(
        initialPosition: position,
        emoji: emoji,
      ),
    );

    rollNextEmoji();

    Future.delayed(const Duration(milliseconds: 1000), () {
      _canDrop = true;
    });
  }

  void reset() {
    _canDrop = true;
  }
}
