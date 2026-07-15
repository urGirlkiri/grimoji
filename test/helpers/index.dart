import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/models/tile.dart';

class TestHelpers {
  static void genDeadLockGrid(GameEngine engine) {
    final colors = [Emojis.fire, Emojis.rock, Emojis.droplet, Emojis.alien];
    for (int r = 0; r < engine.grid.length; r++) {
      for (int c = 0; c < engine.grid[0].length; c++) {
        engine.grid[r][c].emoji = colors[(r + 2 * c) % 4];
      }
    }
  }

  static void expectTile(BoardManager board, int r, int c, GameEmoji emoji) {
    expect(
      board.gridTiles[r][c].emoji,
      equals(emoji),
      reason: 'Tile at ($r, $c) should be $emoji',
    );
  }

  static void expectRow(BoardManager board, int r, List<GameEmoji> emojis) {
    for (int c = 0; c < emojis.length; c++) {
      expectTile(board, r, c, emojis[c]);
    }
  }
}

List<Tile> buildRow(int rowIdx, List<GameEmoji> emojis) {
  return List.generate(
    emojis.length,
    (colIdx) => Tile(
      coordinate: TileCoordinate(row: rowIdx, col: colIdx),
      emoji: emojis[colIdx],
    ),
  );
}
