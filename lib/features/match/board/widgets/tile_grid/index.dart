import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/shuffle.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/flight.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/index.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
import 'package:provider/provider.dart';

class TileGrid extends StatefulWidget {
  static const shuffleDuration = Duration(milliseconds: 600);

  final String? activeTileId;
  final double tWidth;
  final double tHeight;

  const TileGrid({
    super.key,
    this.activeTileId,
    required this.tWidth,
    required this.tHeight,
  });

  @override
  State<TileGrid> createState() => _TileGridState();
}

class _TileGridState extends State<TileGrid> {
  final Set<String> _scheduledFlyTiles = {};

  void _initialFall(LevelState levelState) {
    if (levelState.boardManager.gridTiles[0][0].coordinate.row >= 0) return;

    Future.microtask(() {
      if (!mounted) return;
      levelState.coordinator.startInitialDrop();
      levelState.startLevel();
    });
  }

  void _launchTargetEmo(
    Tile tile,
    LevelState levelState,
    double leftPixel,
    double topPixel,
  ) {
    if (_scheduledFlyTiles.contains(tile.id)) return;
    _scheduledFlyTiles.add(tile.id);

    tile.hasFlown = true;
    context.readAudio.playSfx(SfxType.targetFlight);

    final targetKey = levelState.targetIconKey;

    Future.microtask(() {
      if (!mounted) return;

      final RenderBox? boardBox = context.findRenderObject() as RenderBox?;
      if (boardBox == null) return;

      final Offset globalStart = boardBox.localToGlobal(
        Offset(leftPixel, topPixel),
      );

      final int randomDelay = Random().nextInt(200);

      Future.delayed(Duration(milliseconds: randomDelay), () {
        if (!mounted) return;
        if (targetKey.currentContext == null) return;
        TargetFlightAnimator.launch(
          context: context,
          startOffset: globalStart,
          targetKey: targetKey,
          emoji: tile.emoji,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final targetEmoji = context.select<LevelState, GameEmoji>(
      (s) => s.level.targetEmoji,
    );

    context.select<LevelState, int>((s) => s.gameState.updateToken);

    final levelState = context.read<LevelState>();

    _initialFall(levelState);

    final double tWidth = widget.tWidth;
    final double tHeight = widget.tHeight;
    final grid = levelState.boardManager.gridTiles;

    List<Widget> tileWidgets = [];
    int nRol = grid.length;
    int nCol = grid[0].length;

    for (int r = 0; r < nRol; r++) {
      for (int c = 0; c < nCol; c++) {
        final tile = grid[r][c];

        final double leftPixel =
            (tile.coordinate.col * tWidth) +
            (tile.coordinate.col * tileSpacingGap);
        final double topPixel =
            (tile.coordinate.row * tHeight) +
            (tile.coordinate.row * tileSpacingGap);

        bool isTargetMatch = (tile.emoji == targetEmoji);
        bool shouldFly = tile.isFlying && !tile.hasFlown && isTargetMatch;

        if (shouldFly) {
          _launchTargetEmo(tile, levelState, leftPixel, topPixel);
        }

        tileWidgets.add(
          TileWidget(
            key: ValueKey(tile.id),
            tile: tile,
            leftPixel: leftPixel,
            topPixel: topPixel,
            tWidth: tWidth,
            tHeight: tHeight,
            emoji: tile.emoji,
            isTouched: tile.id == widget.activeTileId,
          ),
        );
      }
    }

    final double boardWidth = (nCol * tWidth) + ((nCol - 1) * tileSpacingGap);

    return ShuffleAnimator(
      boardWidth: boardWidth,
      child: Stack(children: tileWidgets),
    );
  }
}
