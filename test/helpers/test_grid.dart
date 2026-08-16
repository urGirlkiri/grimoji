import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/models/tile.dart';

class TestGrid {
  final BoardManager board;

  TestGrid(this.board);

  void fill(GameEmoji emoji) {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        _setEmoji(board.gridTiles[r][c], emoji);
      }
    }
  }

  void place(int r, int c, GameEmoji emoji) {
    _setEmoji(board.gridTiles[r][c], emoji);
  }

  void fillRow(int r, GameEmoji emoji) {
    for (int c = 0; c < BoardManager.cols; c++) {
      _setEmoji(board.gridTiles[r][c], emoji);
    }
  }

  void fillCol(int c, GameEmoji emoji) {
    for (int r = 0; r < BoardManager.rows; r++) {
      _setEmoji(board.gridTiles[r][c], emoji);
    }
  }

  void fillPattern(List<GameEmoji> pattern) {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        _setEmoji(
          board.gridTiles[r][c],
          pattern[(r * BoardManager.cols + c) % pattern.length],
        );
      }
    }
  }

  void _setEmoji(Tile tile, GameEmoji emoji) {
    tile.emoji = emoji;
    tile.reset();
    tile.clearBehavior();
  }
}
