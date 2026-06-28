import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';

class MatchGroup {
  final GameEmoji emoji;
  final Set<TileCoordinate> coordinates;

  final GameEmoji? yields;
  final TileCoordinate? pivot;

  bool get isSpecial => yields != null;

  MatchGroup({
    required this.emoji,
    required this.coordinates,
    this.yields,
    this.pivot,
  });
}

class MatchDetector {
  static final Set<GameEmoji> unmatchableEmojis = {Emojis.hole};

  static final GameEmoji _twoBytwoYield = Emojis.ghost;
  static final GameEmoji _pivotShapeYield = Emojis.bomb;
  static final GameEmoji _lineYield = Emojis.hole;

  static List<MatchGroup> findMatchedGroups(List<List<Tile>> grid) {
    return _detectMatches(grid);
  }

  static List<MatchGroup> findMatchesInVectors({
    required List<List<Tile>> grid,
    required Set<int> affectedColumns,
    required Set<int> affectedRows,
  }) {
    return _detectMatches(grid);
  }

  static List<MatchGroup> _detectMatches(List<List<Tile>> grid) {
    final rows = grid.length;
    final cols = grid[0].length;

    final horizontalRuns = _scanGrid(grid, isHorizontal: true);
    final verticalRuns = _scanGrid(grid, isHorizontal: false);

    final consumed = <TileCoordinate>{};
    final groups = <MatchGroup>[];

    for (final run in [...horizontalRuns, ...verticalRuns]) {
      if (run.coordinates.length >= 5) {
        final pivot = _runPivot(run.coordinates);
        groups.add(
          MatchGroup(
            emoji: run.emoji,
            coordinates: run.coordinates,
            yields: _lineYield,
            pivot: pivot,
          ),
        );
        consumed.addAll(run.coordinates);
      }
    }

    for (final hRun in horizontalRuns) {
      for (final vRun in verticalRuns) {
        if (hRun.emoji != vRun.emoji) continue;
        if (hRun.coordinates.length < 3 || vRun.coordinates.length < 3) {
          continue;
        }

        final intersection = _intersectionOf(hRun, vRun);
        if (intersection == null) continue;
        if (consumed.contains(intersection)) continue;

        final shapeCoords = hRun.coordinates.union(vRun.coordinates);
        if (shapeCoords.every(consumed.contains)) continue;

        final pivot = intersection;
        final shapeCells = shapeCoords.difference(consumed);
        if (shapeCells.isEmpty) continue;

        final effectiveCoords = shapeCells..add(pivot);

        groups.add(
          MatchGroup(
            emoji: hRun.emoji,
            coordinates: effectiveCoords,
            yields: _pivotShapeYield,
            pivot: pivot,
          ),
        );
        consumed.addAll(effectiveCoords);
      }
    }

    for (int r = 0; r < rows - 1; r++) {
      for (int c = 0; c < cols - 1; c++) {
        final cells = {
          TileCoordinate(row: r, col: c),
          TileCoordinate(row: r, col: c + 1),
          TileCoordinate(row: r + 1, col: c),
          TileCoordinate(row: r + 1, col: c + 1),
        };
        if (cells.any(consumed.contains)) continue;

        final emojis = cells.map((coord) => grid[coord.row][coord.col].emoji);
        if (emojis.every((emoji) => emoji == emojis.first) &&
            !unmatchableEmojis.contains(emojis.first)) {
          groups.add(
            MatchGroup(
              emoji: emojis.first,
              coordinates: cells,
              yields: _twoBytwoYield,
              pivot: TileCoordinate(row: r, col: c),
            ),
          );
          consumed.addAll(cells);
        }
      }
    }

    groups.addAll(
      _scanRemainingRuns(grid: grid, consumed: consumed, isHorizontal: true),
    );
    groups.addAll(
      _scanRemainingRuns(grid: grid, consumed: consumed, isHorizontal: false),
    );

    return groups;
  }

  static TileCoordinate _runPivot(Set<TileCoordinate> coords) {
    final sorted = coords.toList()
      ..sort((a, b) {
        final rowCompare = a.row.compareTo(b.row);
        if (rowCompare != 0) return rowCompare;
        return a.col.compareTo(b.col);
      });
    return sorted[sorted.length ~/ 2];
  }

  static TileCoordinate resolveShapePivot(
    MatchGroup group, {
    TileCoordinate? swipeTarget,
  }) {
    if (swipeTarget != null && group.coordinates.contains(swipeTarget)) {
      if (_isTwoByTwo(group) || _isLShape(group)) {
        return swipeTarget;
      }
    }
    return group.pivot ?? group.coordinates.first;
  }

  static int _neighbourCount(MatchGroup group, TileCoordinate cell) {
    const deltas = [(-1, 0), (1, 0), (0, -1), (0, 1)];

    var count = 0;
    for (final (dr, dc) in deltas) {
      final neighbour = TileCoordinate(row: cell.row + dr, col: cell.col + dc);
      if (group.coordinates.contains(neighbour)) count++;
    }
    return count;
  }

  static bool _isTwoByTwo(MatchGroup group) {
    if (group.coordinates.length != 4) return false;
    final rows = group.coordinates.map((c) => c.row).toSet();
    final cols = group.coordinates.map((c) => c.col).toSet();
    if (rows.length != 2 || cols.length != 2) return false;

    for (final r in rows) {
      for (final c in cols) {
        if (!group.coordinates.contains(TileCoordinate(row: r, col: c))) {
          return false;
        }
      }
    }
    return true;
  }

  static bool _isLShape(MatchGroup group) {
    if (group.coordinates.length != 5) return false;
    return group.coordinates.every((c) => _neighbourCount(group, c) <= 2) &&
        group.coordinates.any((c) => _neighbourCount(group, c) == 2);
  }

  static TileCoordinate? _intersectionOf(MatchGroup hRun, MatchGroup vRun) {
    final hRow = hRun.coordinates.first.row;
    final vCol = vRun.coordinates.first.col;

    final hCols = hRun.coordinates.map((c) => c.col).toSet();
    final vRows = vRun.coordinates.map((c) => c.row).toSet();

    if (hCols.contains(vCol) && vRows.contains(hRow)) {
      return TileCoordinate(row: hRow, col: vCol);
    }
    return null;
  }

  static List<MatchGroup> _scanRemainingRuns({
    required List<List<Tile>> grid,
    required Set<TileCoordinate> consumed,
    required bool isHorizontal,
  }) {
    final groups = <MatchGroup>[];
    final outerLimit = isHorizontal ? grid.length : grid[0].length;
    final innerLimit = isHorizontal ? grid[0].length : grid.length;

    for (int i = 0; i < outerLimit; i++) {
      // ignore: unused_local_variable
      int streak = 0;
      GameEmoji? currentEmoji;
      final streakCoords = <TileCoordinate>[];

      for (int j = 0; j < innerLimit; j++) {
        final coord = TileCoordinate(
          row: isHorizontal ? i : j,
          col: isHorizontal ? j : i,
        );
        final tile = grid[coord.row][coord.col];
        final matchable = !unmatchableEmojis.contains(tile.emoji);

        if (consumed.contains(coord) ||
            !matchable ||
            tile.emoji != currentEmoji) {
          _flushStreak(
            currentEmoji: currentEmoji,
            streakCoords: streakCoords,
            groups: groups,
          );
          streak = 0;
          currentEmoji = null;
          streakCoords.clear();

          if (!consumed.contains(coord) && matchable) {
            streak = 1;
            currentEmoji = tile.emoji;
            streakCoords.add(coord);
          }
        } else {
          streak++;
          streakCoords.add(coord);
        }
      }

      _flushStreak(
        currentEmoji: currentEmoji,
        streakCoords: streakCoords,
        groups: groups,
      );
    }
    return groups;
  }

  static void _flushStreak({
    GameEmoji? currentEmoji,
    required List<TileCoordinate> streakCoords,
    required List<MatchGroup> groups,
  }) {
    if (currentEmoji != null && streakCoords.length >= 3) {
      groups.add(
        MatchGroup(emoji: currentEmoji, coordinates: streakCoords.toSet()),
      );
    }
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
