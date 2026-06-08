import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/game/board/models/tile.dart';
import 'package:grimoji/features/game/board/widgets/tile_grid/tile/tile_content/hint.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class TileDisp extends StatelessWidget {
  final Tile tile;
  final GameEmoji displayEmoji;
  final double tWidth;
  final double tHeight;

  const TileDisp({super.key, 
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
          Widget transition = FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );

          if (tile.isTransmuting) {
            transition = RotationTransition(
              turns: Tween<double>(begin: -0.5, end: 0.0).animate(animation),
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
    );
  }
}
