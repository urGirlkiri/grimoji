import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/utils/manager.dart';

class TestGrid {
  final BoardManager board;

  TestGrid(this.board);

  void fill(GameEmoji emoji) {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        board.gridTiles[r][c].emoji = emoji;
      }
    }
  }

  void place(int r, int c, GameEmoji emoji) {
    board.gridTiles[r][c].emoji = emoji;
  }

  void fillRow(int r, GameEmoji emoji) {
    for (int c = 0; c < BoardManager.cols; c++) {
      board.gridTiles[r][c].emoji = emoji;
    }
  }

  void fillCol(int c, GameEmoji emoji) {
    for (int r = 0; r < BoardManager.rows; r++) {
      board.gridTiles[r][c].emoji = emoji;
    }
  }

  void fillPattern(List<GameEmoji> pattern) {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        board.gridTiles[r][c].emoji =
            pattern[(r * BoardManager.cols + c) % pattern.length];
      }
    }
  }
}
