import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/game/board/models/tile.dart';
import 'package:grimoji/features/game/board/widgets/tile_grid/tile/tile_v_f_x/explosion.dart';
import 'package:grimoji/features/game/board/widgets/tile_grid/tile/tile_v_f_x/match.dart';
import 'package:grimoji/utils/context_data.dart';

class TileVFX extends StatelessWidget {
  final Tile tile;
  final GameEmoji displayEmoji;
  final double tWidth;

  const TileVFX({super.key, 
    required this.tile,
    required this.displayEmoji,
    required this.tWidth,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final reaction = RecipeBook.getReactionFor(displayEmoji);
    final isExplosive =
        reaction != null && reaction.type == ReactionType.explosive;

    if (tile.isExploding) {
      return isExplosive
          ? TileExplosion(size: tWidth)
          : TileMatch(size: tWidth, color: palette.mist);
    }

    return const SizedBox.shrink();
  }
}
