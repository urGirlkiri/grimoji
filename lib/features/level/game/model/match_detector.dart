import 'package:grimoji/features/level/game/model/tile.dart';
import 'package:grimoji/features/level/game/model/coordinate.dart';

class MatchDetector {
  
  static Set<TileCoordinate> findMatches(List<List<Tile>> grid) {
    Set<TileCoordinate> matchedCoordinates = {};
    int rows = grid.length;
    int cols = grid[0].length;

    for (int r = 0; r < rows; r++) {
      int streak = 1;
      
      for (int c = 0; c < cols - 1; c++) {
        if (grid[r][c].emoji == grid[r][c + 1].emoji) {
          streak++;
        } else {
          if (streak >= 3) {
            for (int i = 0; i < streak; i++) {
              matchedCoordinates.add(TileCoordinate(row: r, col: c - i));
            }
          }
          streak = 1; 
        }
      }
      if (streak >= 3) {
        for (int i = 0; i < streak; i++) {
          matchedCoordinates.add(TileCoordinate(row: r, col: (cols - 1) - i));
        }
      }
    }

    for (int c = 0; c < cols; c++) {
      int streak = 1;
      
      for (int r = 0; r < rows - 1; r++) {
        if (grid[r][c].emoji == grid[r + 1][c].emoji) {
          streak++;
        } else {
          if (streak >= 3) {
            for (int i = 0; i < streak; i++) {
              matchedCoordinates.add(TileCoordinate(row: r - i, col: c));
            }
          }
          streak = 1;
        }
      }
      if (streak >= 3) {
        for (int i = 0; i < streak; i++) {
          matchedCoordinates.add(TileCoordinate(row: (rows - 1) - i, col: c));
        }
      }
    }

    return matchedCoordinates;
  }
}