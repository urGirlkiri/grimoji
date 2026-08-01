import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/swallow.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_content/index.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_v_f_x/index.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:grimoji/widgets/painters/crack.dart';

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

    if (tile.isBloodTarget) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          content,
          AnimatedOpacity(
            opacity: tile.isLineClearTrigger ? 0.0 : 1.0,
            duration: lineClearBeamDuration,
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                palette.crimson,
                BlendMode.srcIn,
              ),
              child: EmojiWidget(
                assetPath: 'assets/emojis/svg/cross_barber_pole.svg',
                size: tWidth * emojiSizeFactor,
              ),
            ),
          ),
        ],
      );
    }

    if (tile.isSwallowTrigger) {
      content = content
          .animate()
          .scale(
            begin: Offset.zero,
            end: const Offset(1.1, 1.1),
            duration: 150.ms,
            curve: Curves.easeOutBack,
          )
          .then()
          .shake(hz: 8, duration: 200.ms, curve: Curves.linear)
          .rotate(begin: 0, end: -6, duration: 450.ms, curve: Curves.linear)
          .then()
          .scale(end: Offset.zero, duration: 150.ms, curve: Curves.easeInBack);
    }

    if (tile.isLineClearTrigger && !tile.isBloodTarget) {
      content = content
          .animate()
          .scaleXY(
            begin: 1.0,
            end: 1.4,
            duration: lineClearBeamDuration,
            curve: Curves.easeOutBack,
          )
          .then()
          .scaleXY(
            begin: 1.4,
            end: 0,
            duration: lineClearBeamDuration,
            curve: Curves.easeInBack,
          );
    }

    if (tile.isLineClearTarget) {
      content = content.animate().scaleXY(
        begin: 1.0,
        end: 0,
        duration: lineClearBeamDuration * 2 - 100.ms,
      );
    }

    if (tile.isGhostTarget) {
      content = content.animate().scaleXY(
        begin: 1.0,
        end: 0,
        duration: ghostDiveDuration,
        curve: Curves.easeInExpo,
      );
    }

    return AnimatedPositioned(
      duration: swapSpeed,
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
                SwallowEffect(
                  size: tWidth,
                  isSwallowing: tile.isSwallowTarget && !tile.isSwallowTrigger,
                  child: content,
                ),

                TileVFX(tile: tile, displayEmoji: displayEmoji, tWidth: tWidth),

                if (tile.isTransmuting)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 50),
                    opacity: tile.isTransmuting ? 1.0 : 0.0,
                    child: EmojiWidget.lottie(
                      emoji: tile.emoji,
                      size: tWidth * emojiSizeFactor,
                    ),
                  ),

                if (tile.isBloodTarget && tile.isLineClearTrigger)
                  FissureCracks(size: tWidth, color: Colors.white),
              ],
            ),
          );
        },
      ),
    );
  }
}
