import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_content/disp.dart';

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

    final disp = TileDisp(
      tile: tile,
      displayEmoji: displayEmoji,
      tWidth: tWidth,
      tHeight: tHeight,
    );

    if (tile.isWheelOrigin) {
      return disp
          .animate()
          .scaleXY(
            begin: 1.0,
            end: wheelVisualScaleFactor,
            duration: wheelWindUpDuration,
            curve: Curves.easeOut,
          )
          .then()
          .fadeOut(duration: 1.ms);
    }

    return AnimatedOpacity(
      opacity: targetOpacity,
      duration: 300.ms,
      child: AnimatedScale(
        scale: targetScale,
        duration: scaleDuration,
        curve: scaleCurve,
        child: tile.isTriggered
            ? disp
                  .animate(onPlay: (controller) => controller.repeat())
                  .shake(hz: 5, rotation: 0.1, curve: Curves.easeInOut)
            : disp,
      ),
    );
  }
}
