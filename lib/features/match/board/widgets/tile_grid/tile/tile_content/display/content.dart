import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/clear.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_content/display/shuffler.dart';
import 'package:grimoji/utils/math.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class DisplayContent extends StatelessWidget {
  final Tile tile;
  final GameEmoji displayEmoji;
  final double size;

  const DisplayContent({super.key, 
    required this.tile,
    required this.displayEmoji,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    Widget emojiWidget;

    if (tile.isGhostBombTarget) {
      emojiWidget = EmojiWidget.lottie(
        key: ValueKey('ghost_bomb_target_${tile.id}'),
        emoji: displayEmoji,
        size: size,
        repeat: false,
      );
    } else if (tile.isClownShuffling && tile.emoji == Emojis.clown) {
      emojiWidget = EmojiWidget.lottie(
        key: ValueKey('clown_lottie_${tile.id}'),
        emoji: tile.emoji,
        size: size,
      );
    } else if (tile.isShuffling) {
      emojiWidget = EmojiShuffler(
        key: ValueKey('cycler_${tile.id}'),
        size: size,
      );
    } else {
      emojiWidget = EmojiWidget.svg(
        key: ValueKey(displayEmoji.visual),
        emoji: displayEmoji,
        size: size,
      );
    }

    final behavior = tile.behavior;
    if (behavior is ClearBehavior) {
      return Transform.rotate(
        angle: behavior.isHorizontal ? 0 : degToRad(90),
        child: emojiWidget,
      );
    }

    return emojiWidget;
  }
}
