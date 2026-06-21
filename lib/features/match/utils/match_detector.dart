import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';

class MatchGroup {
  final GameEmoji emoji;
  final Set<TileCoordinate> coordinates;

  MatchGroup({required this.emoji, required this.coordinates});
}

class MatchDetector {
  static final Set<GameEmoji> unmatchableEmojis = {Emojis.hole};

  static List<MatchGroup> findMatchedGroups(List<List<Tile>> grid) {
    List<MatchGroup> groups = [];

    groups.addAll(_scanGrid(grid, isHorizontal: true));
    groups.addAll(_scanGrid(grid, isHorizontal: false));

    return groups;
  }

  static List<MatchGroup> findMatchesInVectors({
    required List<List<Tile>> grid,
    required Set<int> affectedColumns,
    required Set<int> affectedRows,
  }) {
    final List<MatchGroup> groups = [];

    for (final int col in affectedColumns) {
      int streak = 1;
      for (int row = 0; row < grid.length; row++) {
        bool isLast = (row == grid.length - 1);

        Tile currentTile = grid[row][col];
        Tile? nextTile = isLast ? null : grid[row + 1][col];

        if (nextTile != null &&
            currentTile.emoji == nextTile.emoji &&
            !unmatchableEmojis.contains(currentTile.emoji)) {
          streak++;
        } else {
          if (streak >= 3) {
            final coords = <TileCoordinate>{};
            for (int k = 0; k < streak; k++) {
              coords.add(TileCoordinate(row: row - k, col: col));
            }
            groups.add(
              MatchGroup(emoji: currentTile.emoji, coordinates: coords),
            );
          }
          streak = 1;
        }
      }
    }

    for (final int row in affectedRows) {
      int streak = 1;
      for (int col = 0; col < grid[0].length; col++) {
        bool isLast = (col == grid[0].length - 1);

        Tile currentTile = grid[row][col];
        Tile? nextTile = isLast ? null : grid[row][col + 1];

        if (nextTile != null &&
            currentTile.emoji == nextTile.emoji &&
            !unmatchableEmojis.contains(currentTile.emoji)) {
          streak++;
        } else {
          if (streak >= 3) {
            final coords = <TileCoordinate>{};
            for (int k = 0; k < streak; k++) {
              coords.add(TileCoordinate(row: row, col: col - k));
            }
            groups.add(
              MatchGroup(emoji: currentTile.emoji, coordinates: coords),
            );
          }
          streak = 1;
        }
      }
    }

    return groups;
  }

  static List<MatchGroup> _scanGrid(
    List<List<Tile>> grid, {
    required bool isHorizontal,
  }) {
    List<MatchGroup> groups = [];
    int outerLimit = isHorizontal ? grid.length : grid[0].length;
    int innerLimit = isHorizontal ? grid[0].length : grid.length;

    for (int i = 0; i < outerLimit; i++) {
      int streak = 1;
      for (int j = 0; j < innerLimit; j++) {
        bool isLast = (j == innerLimit - 1);

        Tile currentTile = isHorizontal ? grid[i][j] : grid[j][i];
        Tile? nextTile = isLast
            ? null
            : (isHorizontal ? grid[i][j + 1] : grid[j + 1][i]);

        if (nextTile != null &&
            currentTile.emoji == nextTile.emoji &&
            !unmatchableEmojis.contains(currentTile.emoji)) {
          streak++;
        } else {
          if (streak >= 3) {
            final coords = <TileCoordinate>{};
            for (int k = 0; k < streak; k++) {
              coords.add(
                TileCoordinate(
                  row: isHorizontal ? i : j - k,
                  col: isHorizontal ? j - k : i,
                ),
              );
            }
            groups.add(
              MatchGroup(emoji: currentTile.emoji, coordinates: coords),
            );
          }
          streak = 1;
        }
      }
    }
    return groups;
  }

  static bool hasMatchAt(List<List<Tile>> grid, int row, int col) {
    if (unmatchableEmojis.contains(grid[row][col].emoji)) return false;

    if (_hasMatchInDirection(grid, row, col, 0, 1)) return true;
    if (_hasMatchInDirection(grid, row, col, 1, 0)) return true;

    return false;
  }

  static bool _hasMatchInDirection(
    List<List<Tile>> grid,
    int startRow,
    int startCol,
    int rowDir,
    int colDir,
  ) {
    int rows = grid.length;
    int cols = grid[0].length;
    GameEmoji emoji = grid[startRow][startCol].emoji;

    if (unmatchableEmojis.contains(emoji)) return false;

    int streak = 1;

    int r = startRow - rowDir;
    int c = startCol - colDir;
    while (r >= 0 && r < rows && c >= 0 && c < cols) {
      if (grid[r][c].emoji == emoji) {
        streak++;
        r -= rowDir;
        c -= colDir;
      } else {
        break;
      }
    }

    r = startRow + rowDir;
    c = startCol + colDir;
    while (r >= 0 && r < rows && c >= 0 && c < cols) {
      if (grid[r][c].emoji == emoji) {
        streak++;
        r += rowDir;
        c += colDir;
      } else {
        break;
      }
    }

    return streak >= 3;
  }
}
