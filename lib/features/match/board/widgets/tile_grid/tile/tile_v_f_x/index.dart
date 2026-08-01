import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/reactions/models/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_v_f_x/explosion.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_v_f_x/match.dart';

class TileVFX extends StatelessWidget {
  final Tile tile;
  final GameEmoji displayEmoji;
  final double tWidth;

  const TileVFX({
    super.key,
    required this.tile,
    required this.displayEmoji,
    required this.tWidth,
  });

  @override
  Widget build(BuildContext context) {
    
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
