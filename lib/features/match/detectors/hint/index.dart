import 'package:flutter/foundation.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/models/hint_scan_args.dart';
import 'package:grimoji/features/match/models/iso_group.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/utils/manager.dart';
import 'package:grimoji/features/match/detectors/match.dart';
import 'package:grimoji/config/emojis/index.dart';

class HintDetector {
  static Future<List<TileCoordinate>?> findBestMove({
    required List<List<Tile>> grid,
    required GameEmoji targetEmoji,
  }) async {
    final gridSnapshot = grid
        .map((row) => row.map((t) => t.emoji.visual).toList())
        .toList();
    final hasBehaviorGrid = grid
        .map((row) => row.map((t) => t.behavior != null).toList())
        .toList();
    final targetIngredients = RecipeBook.allRecipes
        .where((r) => r.yields == targetEmoji)
        .map((r) => r.ingredient.visual)
        .toSet();
    final unmatchableVisuals = MatchDetector.unmatchableEmojis
        .map((e) => e.visual)
        .toSet();

    final result = await compute(
      isolate,
      HintScanArgs(
        gridVisuals: gridSnapshot,
        hasBehavior: hasBehaviorGrid,
        rows: BoardManager.rows,
        cols: BoardManager.cols,
        targetVisual: targetEmoji.visual,
        targetIngredients: targetIngredients,
        unmatchableVisuals: unmatchableVisuals,
      ),
    );

    if (result == null) return null;
    return [
      TileCoordinate(row: result[0], col: result[1]),
      TileCoordinate(row: result[2], col: result[3]),
      TileCoordinate(row: result[4], col: result[5]),
    ];
  }
}

List<int>? isolate(HintScanArgs args) {
  final rows = args.rows;
  final cols = args.cols;
  final g = List<List<String>>.from(
    args.gridVisuals.map((r) => List<String>.from(r)),
  );
  final unmatchable = args.unmatchableVisuals;

  final List<
    ({List<int> coords, int score, int completingRow, int completingCol})
  >
  validMoves = [];

  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      if (c < cols - 1) {
        final score = scoreHintMove(
          g,
          r,
          c,
          r,
          c + 1,
          rows,
          cols,
          args,
          unmatchable,
        );
        if (score != null) {
          final completingInfo = findCompletingTile(
            g,
            r,
            c,
            r,
            c + 1,
            rows,
            cols,
            unmatchable,
          );
          validMoves.add((
            coords: [r, c, r, c + 1],
            score: score,
            completingRow: completingInfo.$1,
            completingCol: completingInfo.$2,
          ));
        }
      }
      if (r < rows - 1) {
        final score = scoreHintMove(
          g,
          r,
          c,
          r + 1,
          c,
          rows,
          cols,
          args,
          unmatchable,
        );
        if (score != null) {
          final completingInfo = findCompletingTile(
            g,
            r,
            c,
            r + 1,
            c,
            rows,
            cols,
            unmatchable,
          );
          validMoves.add((
            coords: [r, c, r + 1, c],
            score: score,
            completingRow: completingInfo.$1,
            completingCol: completingInfo.$2,
          ));
        }
      }
    }
  }

  if (validMoves.isEmpty) return null;
  validMoves.sort((a, b) => b.score.compareTo(a.score));
  final topScore = validMoves.first.score;
  final best = validMoves.where((m) => m.score == topScore).toList();
  if (best.length > 1) {
    best.sort((a, b) => b.completingRow.compareTo(a.completingRow));
  }
  final selected = best.first;
  return [
    selected.coords[0],
    selected.coords[1],
    selected.coords[2],
    selected.coords[3],
    selected.completingRow,
    selected.completingCol,
  ];
}

(int, int) findCompletingTile(
  List<List<String>> g,
  int r1,
  int c1,
  int r2,
  int c2,
  int rows,
  int cols,
  Set<String> unmatchable,
) {
  final tmp = g[r1][c1];
  g[r1][c1] = g[r2][c2];
  g[r2][c2] = tmp;

  final matchedCells = <(int, int)>{};

  for (int r = 0; r < rows; r++) {
    int start = 0;

    while (start < cols) {
      int end = start + 1;

      while (end < cols &&
          g[r][end] == g[r][start] &&
          !unmatchable.contains(g[r][start])) {
        end++;
      }

      if (end - start >= 3) {
        for (int c = start; c < end; c++) {
          matchedCells.add((r, c));
        }
      }

      start = end;
    }
  }

  for (int c = 0; c < cols; c++) {
    int start = 0;

    while (start < rows) {
      int end = start + 1;

      while (end < rows &&
          g[end][c] == g[start][c] &&
          !unmatchable.contains(g[start][c])) {
        end++;
      }

      if (end - start >= 3) {
        for (int r = start; r < end; r++) {
          matchedCells.add((r, c));
        }
      }

      start = end;
    }
  }

  g[r2][c2] = g[r1][c1];
  g[r1][c1] = tmp;

  final position1Matched = matchedCells.contains((r1, c1));
  final position2Matched = matchedCells.contains((r2, c2));

  if (position1Matched && !position2Matched) {}

  if (position2Matched && !position1Matched) {}

  return (r2, c2);
}

int? scoreHintMove(
  List<List<String>> g,
  int r1,
  int c1,
  int r2,
  int c2,
  int rows,
  int cols,
  HintScanArgs args,
  Set<String> unmatchable,
) {
  final tmp = g[r1][c1];
  g[r1][c1] = g[r2][c2];
  g[r2][c2] = tmp;

  final matched = scanMatchGroups(g, rows, cols, unmatchable);

  g[r2][c2] = g[r1][c1];
  g[r1][c1] = tmp;

  if (matched.isEmpty) return null;

  int score = 100;

  final totalMatchSize = matched.fold<int>(0, (sum, group) => sum + group.size);

  score += (totalMatchSize - 3) * 25;

  if (matched.any((m) => m.isSpecial)) {
    score += 75;
  }

  for (final group in matched) {
    if (group.yieldEmoji == Emojis.ghost.visual) {
      score += 150;
    } else if (group.yieldEmoji == Emojis.bomb.visual) {
      score += 200;
    } else if (group.yieldEmoji == Emojis.hole.visual) {
      score += 100;
    }
  }

  if (args.targetIngredients.contains(g[r1][c1]) ||
      args.targetIngredients.contains(g[r2][c2])) {
    score += 1000;
  }

  if (matched.any((m) => m.emoji == args.targetVisual)) {
    score += double.infinity.toInt();
    final targetRows = <int>[];
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (g[r][c] == args.targetVisual) {
          targetRows.add(r);
        }
      }
    }
    if (targetRows.isNotEmpty) {
      final avgTargetRow =
          targetRows.reduce((a, b) => a + b) / targetRows.length;
      final swapAvgRow = (r1 + r2) / 2;
      (swapAvgRow - avgTargetRow).abs();
    }
  }

  return score;
}

List<IsoGroup> scanMatchGroups(
  List<List<String>> g,
  int rows,
  int cols,
  Set<String> unmatchable,
) {
  final groups = <IsoGroup>[];
  final hRuns = <({String emoji, int row, int startCol, int len})>[];
  final vRuns = <({String emoji, int col, int startRow, int len})>[];

  for (int r = 0; r < rows; r++) {
    int streak = 1;
    for (int c = 1; c <= cols; c++) {
      final same =
          c < cols && g[r][c] == g[r][c - 1] && !unmatchable.contains(g[r][c]);
      if (!same) {
        if (streak >= 3) {
          hRuns.add((
            emoji: g[r][c - 1],
            row: r,
            startCol: c - streak,
            len: streak,
          ));
        }
        streak = 1;
      } else {
        streak++;
      }
    }
  }

  for (int c = 0; c < cols; c++) {
    int streak = 1;
    for (int r = 1; r <= rows; r++) {
      final same =
          r < rows && g[r][c] == g[r - 1][c] && !unmatchable.contains(g[r][c]);
      if (!same) {
        if (streak >= 3) {
          vRuns.add((
            emoji: g[r - 1][c],
            col: c,
            startRow: r - streak,
            len: streak,
          ));
        }
        streak = 1;
      } else {
        streak++;
      }
    }
  }

  for (final h in hRuns) {
    bool foundIntersect = false;
    for (final v in vRuns) {
      if (h.emoji != v.emoji) continue;
      final hCols = List.generate(h.len, (i) => h.startCol + i).toSet();
      final vRows = List.generate(v.len, (i) => v.startRow + i).toSet();
      if (hCols.contains(v.col) && vRows.contains(h.row)) {
        final totalSize = h.len + v.len - 1;

        String? yieldEmoji;
        if (totalSize >= 5) {
          yieldEmoji = Emojis.bomb.visual;
        } else {
          yieldEmoji = Emojis.ghost.visual;
        }
        groups.add(
          IsoGroup(
            h.emoji,
            isSpecial: true,
            size: totalSize,
            yieldEmoji: yieldEmoji,
          ),
        );
        foundIntersect = true;
        break;
      }
    }
    if (!foundIntersect) {
      groups.add(IsoGroup(h.emoji, size: h.len));
    }
  }

  for (final v in vRuns) {
    final alreadyCovered = groups.any(
      (grp) => grp.isSpecial && grp.emoji == v.emoji,
    );
    if (!alreadyCovered) {
      String? yieldEmoji;
      if (v.len >= 5) {
        yieldEmoji = Emojis.hole.visual;
      }
      groups.add(IsoGroup(v.emoji, size: v.len, yieldEmoji: yieldEmoji));
    }
  }

  return groups;
}
