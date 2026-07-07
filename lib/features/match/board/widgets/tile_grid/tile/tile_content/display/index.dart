import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_content/display/content.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_content/display/transition.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_content/hint.dart';

class TileDisp extends StatelessWidget {
  final Tile tile;
  final GameEmoji displayEmoji;
  final double tWidth;
  final double tHeight;

  const TileDisp({
    super.key,
    required this.tile,
    required this.displayEmoji,
    required this.tWidth,
    required this.tHeight,
  });

  @override
  Widget build(BuildContext context) {
    return HintNudge(
      isHinting: tile.isHinting,
      current: tile.coordinate,
      partner: tile.hintPartner,
      tileWidth: tWidth,
      tileHeight: tHeight,
      child: AnimatedSwitcher(
        duration: 400.ms,
        transitionBuilder: (child, animation) {
          return TileTransition(
            animation: animation,
            isTransmuting: tile.isTransmuting,
            isShuffling: tile.isShuffling,
            child: child,
          );
        },
        child: DisplayContent(
          tile: tile,
          displayEmoji: displayEmoji,
          size: tWidth * emojiSizeFactor,
        ),
      ),
    );
  }
}
