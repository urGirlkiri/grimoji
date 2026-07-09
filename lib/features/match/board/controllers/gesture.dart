import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/board/controllers/v_f_x.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/board/manager.dart';

class GestureController {
  final ValueNotifier<String?> activeTileIdNotifier = ValueNotifier<String?>(
    null,
  );

  Tile? _draggedTile;
  Offset? _dragStartPosition;

  void onTapped(
    TapUpDetails details,
    double tWidth,
    double tHeight,
    LevelState levelState,
    VFXController vfx,
  ) {
    if (levelState.gameState.isProcessing || levelState.gameState.isShuffling) {
      vfx.triggerSparkle(details.localPosition);
      return;
    }

    int col = (details.localPosition.dx / tWidth).floor();
    int row = (details.localPosition.dy / tHeight).floor();

    if (_isValidCoordinate(row, col, levelState)) {
      levelState.coordinator.resolveTap(TileCoordinate(row: row, col: col));
    }
  }

  void onPanStart(
    DragStartDetails details,
    double tWidth,
    double tHeight,
    LevelState levelState,
    VFXController vfx,
  ) {
    if (levelState.gameState.isProcessing || levelState.gameState.isShuffling) {
      vfx.triggerSparkle(details.localPosition);
      return;
    }

    int col = (details.localPosition.dx / tWidth).floor();
    int row = (details.localPosition.dy / tHeight).floor();

    if (_isValidCoordinate(row, col, levelState)) {
      levelState.coordinator.resetHintTimer();
      _draggedTile = levelState.boardManager.gridTiles[row][col];
      _dragStartPosition = details.localPosition;
      activeTileIdNotifier.value = _draggedTile?.id;
    }
  }

  void onPanUpdate(
    DragUpdateDetails details,
    LevelState levelState,
    VFXController vfx,
  ) {
    if (_draggedTile == null || _dragStartPosition == null) return;

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

      if (_isValidCoordinate(targetRow, targetCol, levelState)) {
        levelState.coordinator.resolveSwipe(
          _draggedTile!.coordinate,
          TileCoordinate(row: targetRow, col: targetCol),
        );
      } else {
        vfx.triggerSparkle(details.localPosition);
      }

      clearDrag();
    }
  }

  void clearDrag() {
    _draggedTile = null;
    _dragStartPosition = null;
    activeTileIdNotifier.value = null;
  }

  bool _isValidCoordinate(int row, int col, LevelState state) {
    return row >= 0 &&
        row < BoardManager.rows &&
        col >= 0 &&
        col < BoardManager.cols;
  }

  void dispose() {
    activeTileIdNotifier.dispose();
  }
}
