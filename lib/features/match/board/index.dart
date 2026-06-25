import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/features/match/board/models/line_clear.dart';
import 'package:grimoji/features/match/board/models/sparkle_effect.dart';
import 'package:grimoji/features/match/board/widgets/announcer/index.dart';
import 'package:grimoji/features/match/board/widgets/overlays/line_clear/index.dart';
import 'package:grimoji/features/match/board/widgets/board_grid/index.dart';
import 'package:grimoji/features/match/board/utils/metrics.dart';
import 'package:grimoji/features/match/board/widgets/overlays/sparkle.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/index.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final GlobalKey _boardKey = GlobalKey();
  final GlobalKey _tileKey = GlobalKey();

  LevelState? _levelState;

  Tile? _draggedTile;
  Offset? _dragStartPosition;

  final ValueNotifier<List<SparkleEffect>> _sparklesNotifier = ValueNotifier(
    [],
  );
  final ValueNotifier<String?> _activeTileIdNotifier = ValueNotifier<String?>(
    null,
  );
  final ValueNotifier<List<LineClearEffect>> _lineClearNotifier = ValueNotifier(
    [],
  );
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureBoard();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLevelState = context.read<LevelState>();
    if (_levelState != newLevelState) {
      _levelState?.coordinator.onLineClear = null;
      _levelState = newLevelState;
      _levelState!.coordinator.onLineClear = triggerLineClear;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _sparklesNotifier.dispose();
    _activeTileIdNotifier.dispose();
    _lineClearNotifier.dispose();
    _levelState?.coordinator.onLineClear = null;
    super.dispose();
  }

  void _measureBoard() {
    if (!mounted) return;

    final boardContext = _boardKey.currentContext;
    final cellContext = _tileKey.currentContext;

    if (boardContext != null && cellContext != null) {
      final boardBox = boardContext.findRenderObject() as RenderBox;
      final cellBox = cellContext.findRenderObject() as RenderBox;
      final boardRect = boardBox.localToGlobal(Offset.zero) & boardBox.size;

      context.read<BoardMetrics>().updateMetrics(
        cellBox.size.width,
        cellBox.size.height,
        boardRect,
      );
    }
  }

  void triggerLineClear(int row, int col, bool isHorizontal) {
    if (_isDisposed) return;
    final effect = LineClearEffect(
      row: row,
      col: col,
      isHorizontal: isHorizontal,
    );
    _lineClearNotifier.value = [..._lineClearNotifier.value, effect];
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_isDisposed) return;
      _lineClearNotifier.value = _lineClearNotifier.value
          .where((e) => e.id != effect.id)
          .toList();
    });
  }

  void _triggerSparkle(Offset localPosition) {
    if (_isDisposed) return;

    final sparkle = SparkleEffect(position: localPosition);
    _sparklesNotifier.value = [..._sparklesNotifier.value, sparkle];

    Future.delayed(boardSparksTime, () {
      if (_isDisposed) return;
      _sparklesNotifier.value = _sparklesNotifier.value
          .where((s) => s.id != sparkle.id)
          .toList();
    });
  }

  void onTapped(TapUpDetails details, BuildContext context) {
    final metrics = context.read<BoardMetrics>();
    final levelState = context.read<LevelState>();

    if (!metrics.isReady) return;

    if (levelState.gameState.isProcessing || levelState.gameState.isShuffling) {
      _triggerSparkle(details.localPosition);
      return;
    }

    int col = (details.localPosition.dx / metrics.tileWidth!).floor();
    int row = (details.localPosition.dy / metrics.tileHeight!).floor();

    if (row >= 0 &&
        row < levelState.boardManager.gridTiles.length &&
        col >= 0 &&
        col < levelState.boardManager.gridTiles[0].length) {
      levelState.coordinator.resolveTap(TileCoordinate(row: row, col: col));
    }
  }

  void _clearDrag() {
    _draggedTile = null;
    _dragStartPosition = null;
    _activeTileIdNotifier.value = null;
  }

  void onPanStart(DragStartDetails details, BuildContext context) {
    final metrics = context.read<BoardMetrics>();
    final levelState = context.read<LevelState>();

    if (!metrics.isReady) return;

    if (levelState.gameState.isProcessing || levelState.gameState.isShuffling) {
      _triggerSparkle(details.localPosition);
      return;
    }

    int col = (details.localPosition.dx / metrics.tileWidth!).floor();
    int row = (details.localPosition.dy / metrics.tileHeight!).floor();

    if (row >= 0 &&
        row < levelState.boardManager.gridTiles.length &&
        col >= 0 &&
        col < levelState.boardManager.gridTiles[0].length) {
      levelState.coordinator.resetHintTimer();

      _draggedTile = levelState.boardManager.gridTiles[row][col];
      _dragStartPosition = details.localPosition;
      _activeTileIdNotifier.value = _draggedTile?.id;
    }
  }

  void onPanUpdate(DragUpdateDetails details, BuildContext context) {
    if (_draggedTile == null || _dragStartPosition == null) return;

    final levelState = context.read<LevelState>();

    final dx = details.localPosition.dx - _dragStartPosition!.dx;
    final dy = details.localPosition.dy - _dragStartPosition!.dy;

    if (dx.abs() > 20 || dy.abs() > 20) {
      int targetRow = _draggedTile!.coordinate.row;
      int targetCol = _draggedTile!.coordinate.col;

      if (dx.abs() > dy.abs()) {
        targetCol += dx > 0 ? 1 : -1;
      } else {
        targetRow += dy > 0 ? 1 : -1;
      }

      if (targetRow >= 0 &&
          targetRow < levelState.boardManager.gridTiles.length &&
          targetCol >= 0 &&
          targetCol < levelState.boardManager.gridTiles[0].length) {
        levelState.coordinator.resolveSwipe(
          _draggedTile!.coordinate,
          TileCoordinate(row: targetRow, col: targetCol),
        );
      } else {
        _triggerSparkle(details.localPosition);
      }

      _clearDrag();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final initialGrid = context.read<LevelState>().boardManager.gridTiles;
    final int gridColumns = initialGrid[0].length;
    final int gridRows = initialGrid.length;

    const double maxAllowedBoardWidth = 350.0;
    final int totalTiles = gridColumns * gridRows;

    return LayoutBuilder(
      builder: (context, screenConstraints) {
        final double screenWidth = screenConstraints.maxWidth;
        final double screenHeight = screenConstraints.maxHeight;
        final bool isSmallScreen = screenWidth < 360 || screenHeight < 600;

        final double constrainedBoardWidth = isSmallScreen
            ? screenWidth * 0.95
            : (screenWidth > maxAllowedBoardWidth
                  ? maxAllowedBoardWidth
                  : screenWidth * 0.9);

        final double proportionalBoardHeight =
            (constrainedBoardWidth * gridRows) / gridColumns;

        return Center(
          child: SizedBox(
            width: constrainedBoardWidth,
            height: proportionalBoardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 6.0 : 8.0),
                  clipBehavior: Clip.hardEdge,
                  decoration: ShapeDecoration(
                    color: palette.mist,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, gridAreaConstraints) {
                      int horizontalGapsCount = gridColumns - 1;
                      int verticalGapsCount = gridRows - 1;

                      final double calculatedSingleTileWidth =
                          (gridAreaConstraints.maxWidth -
                              (tileSpacingGap * horizontalGapsCount)) /
                          gridColumns;
                      final double calculatedSingleTileHeight =
                          (gridAreaConstraints.maxHeight -
                              (tileSpacingGap * verticalGapsCount)) /
                          gridRows;

                      return GestureDetector(
                        onTapUp: (details) => onTapped(details, context),
                        onPanStart: (details) => onPanStart(details, context),
                        onPanUpdate: (details) => onPanUpdate(details, context),
                        onPanEnd: (details) => _clearDrag(),
                        onPanCancel: () => _clearDrag(),
                        child: Stack(
                          key: _boardKey,
                          clipBehavior: Clip.none,
                          children: [
                            BoardGrid(
                              gridColumns: gridColumns,
                              totalTiles: totalTiles,
                              firstTileKey: _tileKey,
                              tWidth: calculatedSingleTileWidth,
                              tHeight: calculatedSingleTileHeight,
                            ),

                            ListenableBuilder(
                              listenable: _activeTileIdNotifier,
                              builder: (context, _) {
                                return TileGrid(
                                  activeTileId: _activeTileIdNotifier.value,
                                );
                              },
                            ),

                            SparkleOverlay(sparklesNotifier: _sparklesNotifier),

                            OverflowBox(
                              maxWidth: constrainedBoardWidth,
                              child: IgnorePointer(
                                child: LineClearOverlay(
                                  notifier: _lineClearNotifier,
                                  tileWidth: calculatedSingleTileWidth,
                                  tileHeight: calculatedSingleTileHeight,
                                  cols: gridColumns,
                                  rows: gridRows,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                OverflowBox(
                  maxWidth: constrainedBoardWidth,
                  child: const AnnouncerWidget(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
