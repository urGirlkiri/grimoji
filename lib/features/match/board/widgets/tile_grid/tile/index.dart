import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

    Widget content = TileContent(
      tile: tile,
      displayEmoji: displayEmoji,
      tWidth: tWidth,
      tHeight: tHeight,
      isTouched: isTouched,
    );

    if (tile.isTaggedForDestruct) {
      content = content.animate()
          .moveY(begin: 0, end: 20, duration: 400.ms, curve: Curves.easeInBack)
          .scale(begin: const Offset(1, 1), end: Offset.zero, duration: 400.ms, curve: Curves.easeInBack);
    }

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
                if (tile.isTaggedForDestruct && tile.emoji != Emojis.hole)
                  Positioned(
                    bottom: -10,
                    child: EmojiWidget.svg(
                      path: Emojis.hole.svg,
                      size: tWidth * 0.8,
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .rotate(duration: 1.seconds, curve: Curves.linear)
                    .scale(begin: Offset.zero, end: const Offset(1, 1), duration: 200.ms) 
                    .then(delay: 300.ms) 
                    .scale(end: Offset.zero, duration: 200.ms),
                  ),

                content,
                
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