import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_content/index.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_v_f_x/index.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class TileWidget extends StatelessWidget {
  const TileWidget({
    super.key,
    required this.tile,
    required this.leftPixel,
    required this.topPixel,
    required this.tWidth,
    required this.tHeight,
    required this.emoji,
    this.isTouched = false,
  });

  final Tile tile;
  final double leftPixel;
  final double topPixel;
  final double tWidth;
  final double tHeight;
  final GameEmoji? emoji;
  final bool isTouched;

  @override
  Widget build(BuildContext context) {
    final displayEmoji = tile.morphTarget ?? tile.emoji;

    return AnimatedPositioned(
      duration: swapAnimationTime,
      curve: Curves.easeOutCubic,
      left: leftPixel,
      top: topPixel,
      width: tWidth,
      height: tHeight,
      child: Builder(
        builder: (context) {
          if (tile.hasFlown) {
            return const SizedBox.shrink();
          }

          return Center(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                TileContent(
                  tile: tile,
                  displayEmoji: displayEmoji,
                  tWidth: tWidth,
                  tHeight: tHeight,
                  isTouched: isTouched,
                ),
                TileVFX(tile: tile, displayEmoji: displayEmoji, tWidth: tWidth),
                if (tile.isTransmuting)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 50),
                    opacity: tile.isTransmuting ? 1.0 : 0.0,
                    child: EmojiWidget.lottie(
                      path: tile.emoji.lottie,
                      size: tWidth * 0.8,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
