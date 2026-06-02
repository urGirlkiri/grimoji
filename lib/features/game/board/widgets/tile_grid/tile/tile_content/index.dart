import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/game/board/models/tile.dart';
import 'package:grimoji/features/game/board/widgets/tile_grid/tile/tile_content/hint.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class TileContent extends StatelessWidget {
  final Tile tile;
  final GameEmoji displayEmoji;
  final double tWidth;
  final double tHeight;
  final bool isTouched;

  const TileContent({
    super.key,
    required this.tile,
    required this.displayEmoji,
    required this.tWidth,
    required this.tHeight,
    this.isTouched = false,
  });

  @override
  Widget build(BuildContext context) {
    final targetScale = tile.isExploding
        ? 0.0
        : tile.isMerging
        ? 0.0
        : tile.isMergePoint
        ? 1.15
        : tile.isTriggered
        ? 1.1
        : isTouched
        ? 1.15
        : 1.0;

    final displayEmoji = tile.morphTarget ?? tile.emoji;
    final reaction = RecipeBook.getReactionFor(displayEmoji);
    final isExplosive = reaction?.type == ReactionType.explosive;
    final targetOpacity = (tile.isExploding && isExplosive) ? 0.0 : 1.0;

    final scaleDuration = (isTouched ? 100 : 200).ms;
    final scaleCurve = tile.isMergePoint
        ? Curves.elasticOut
        : Curves.easeOutBack;

    return AnimatedOpacity(
      opacity: targetOpacity,
      duration: 300.ms,
      child: AnimatedScale(
        scale: targetScale,
        duration: scaleDuration,
        curve: scaleCurve,

        child:
            HintNudge(
                  isHinting: tile.isHinting,
                  current: tile.coordinate,
                  partner: tile.hintPartner,
                  tileWidth: tWidth,
                  tileHeight: tHeight,
                  child: AnimatedSwitcher(
                    duration: 400.ms,
                    transitionBuilder: (child, animation) {
                      Widget transition = FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );

                      if (tile.isTransmuting) {
                        transition = RotationTransition(
                          turns: Tween<double>(
                            begin: -0.5,
                            end: 0.0,
                          ).animate(animation),
                          child: transition,
                        );
                      }
                      return transition;
                    },
                    child: EmojiWidget.svg(
                      key: ValueKey(displayEmoji.visual),
                      path: displayEmoji.svg,
                      size: tWidth * 0.8,
                    ),
                  ),
                )
                .animate(target: tile.isTriggered ? 1 : 0)
                .shake(hz: 5, rotation: 0.1, curve: Curves.easeInOut),
      ),
    );
  }
}
