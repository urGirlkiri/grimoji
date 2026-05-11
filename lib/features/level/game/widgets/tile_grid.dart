import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grimoji/config/board.dart';
import 'package:grimoji/features/level/game/metrics.dart';
import 'package:grimoji/features/level/game/widgets/flight_animation.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/game/model/tile.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:grimoji/widgets/emoji_widget.dart';

class TileGrid extends StatelessWidget {
  const TileGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = context.watch<BoardMetrics>();
    final levelState = context.watch<LevelState>();

    if (!metrics.isReady) {
      return const SizedBox.shrink();
    }

    _initialFall(levelState);

    final double tWidth = metrics.tileWidth!;
    final double tHeight = metrics.tileHeight!;
    final grid = levelState.gameState.gameController.grid;

    List<Widget> tileWidgets = [];

    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        final tile = grid[r][c];

        final double leftPixel =
            (tile.coordinate.col * tWidth) +
            (tile.coordinate.col * tileSpacingGap);
        final double topPixel =
            (tile.coordinate.row * tHeight) +
            (tile.coordinate.row * tileSpacingGap);

        _launchTargetEmo(context, tile, levelState, leftPixel, topPixel);

        tileWidgets.add(
          _buildAnimatedTile(tile, leftPixel, topPixel, tWidth, tHeight),
        );
      }
    }

    return Stack(children: tileWidgets);
  }

  void _initialFall(LevelState levelState) {
    if (levelState.gameState.gameController.grid[0][0].coordinate.row < 0) {
      Future.microtask(() {
        levelState.gameState.startInitialDrop();
        levelState.startLevel();
      });
    }
  }

void _launchTargetEmo(
    BuildContext context,
    Tile tile,
    LevelState levelState,
    double leftPixel,
    double topPixel,
  ) {
    bool isTargetMatch = (tile.emoji == levelState.level.targetEmoji);

    bool shouldFly = tile.isFlying&& !tile.hasFlown && isTargetMatch;

    if (shouldFly) {
      tile.hasFlown = true; 

      Future.microtask(() {
        if (!context.mounted) return;

        final RenderBox? boardBox = context.findRenderObject() as RenderBox?;
        if (boardBox == null) return;

        final Offset globalStart = boardBox.localToGlobal(Offset(leftPixel, topPixel));
        
        final int randomDelay = Random().nextInt(200);

        Future.delayed(Duration(milliseconds: randomDelay), () {
          if(!context.mounted) return;
          TargetFlightAnimator.launch(
            context: context,
            startOffset: globalStart,
            targetKey: levelState.targetIconKey,
            emoji: tile.emoji,
          );
        });
      });
    }
  }

  Widget _buildTileContent(Tile tile, double tWidth, double tHeight) {
    if (tile.hasFlown) {
      return const SizedBox.shrink();
    }
 
    if (tile.isExploding) {
      return Lottie.asset(
        "assets/lottie/stars.json",
        width: tWidth * 500,
        height: tHeight * 500,
        fit: BoxFit.cover,
        animate: true,
        frameRate: const FrameRate(60),
      );
    } else if (tile.isMerging) {
      return Lottie.asset(
        "assets/lottie/puff.json",
        width: tWidth * 500,
        height: tHeight * 500,
        fit: BoxFit.cover,
        animate: true,
        frameRate: const FrameRate(60),
      );
    } else {
      return EmojiWidget.svg(path: tile.emoji.svg, size: tWidth * 0.8);
    }
  }

  Widget _buildAnimatedTile(
    Tile tile,
    double leftPixel,
    double topPixel,
    double tWidth,
    double tHeight,
  ) {
    return AnimatedPositioned(
      key: ValueKey(tile.id),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      left: leftPixel + (tile.isExploding || tile.isMerging ? -20 : 0),
      top: topPixel,
      width: tWidth,
      height: tHeight,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Center(child: _buildTileContent(tile, tWidth, tHeight)),
      ),
    );
  }
}
