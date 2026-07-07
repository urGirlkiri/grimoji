import 'package:flutter/foundation.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
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
      _hintScanIsolate,
      _HintScanArgs(
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
    ];
  }
}

class _HintScanArgs {
  final List<List<String>> gridVisuals;
  final List<List<bool>> hasBehavior;
  final int rows;
  final int cols;
  final String targetVisual;
  final Set<String> targetIngredients;
  final Set<String> unmatchableVisuals;

  _HintScanArgs({
    required this.gridVisuals,
    required this.hasBehavior,
    required this.rows,
    required this.cols,
    required this.targetVisual,
    required this.targetIngredients,
    required this.unmatchableVisuals,
  });
}

List<int>? _hintScanIsolate(_HintScanArgs args) {
  final rows = args.rows;
  final cols = args.cols;
  final g = List<List<String>>.from(
    args.gridVisuals.map((r) => List<String>.from(r)),
  );
  final unmatchable = args.unmatchableVisuals;

  final List<({List<int> coords, int score})> validMoves = [];

  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      if (c < cols - 1) {
        final score = _scoreHintMove(
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
          validMoves.add((coords: [r, c, r, c + 1], score: score));
        }
      }
      if (r < rows - 1) {
        final score = _scoreHintMove(
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
          validMoves.add((coords: [r, c, r + 1, c], score: score));
        }
      }
    }
  }

  if (validMoves.isEmpty) return null;
  validMoves.sort((a, b) => b.score.compareTo(a.score));
  final topScore = validMoves.first.score;
  final best = validMoves.where((m) => m.score == topScore).toList();
  if (best.length > 1) {
    best.sort(
      (a, b) => (b.coords[0] * cols + b.coords[1]).compareTo(
        a.coords[0] * cols + a.coords[1],
      ),
    );
  }
  return best.first.coords;
}

int? _scoreHintMove(
  List<List<String>> g,
  int r1,
  int c1,
  int r2,
  int c2,
  int rows,
  int cols,
  _HintScanArgs args,
  Set<String> unmatchable,
) {
  final tmp = g[r1][c1];
  g[r1][c1] = g[r2][c2];
  g[r2][c2] = tmp;

  final matched = _scanMatchGroups(g, rows, cols, unmatchable);

  g[r2][c2] = g[r1][c1];
  g[r1][c1] = tmp;

  if (matched.isEmpty) return null;

  int score = 100;
  if (matched.any((m) => m.isSpecial)) score += 75;
  if (args.targetIngredients.contains(g[r1][c1]) ||
      args.targetIngredients.contains(g[r2][c2])) {
    score += 50;
  }
  if (matched.any((m) => m.emoji == args.targetVisual)) {
    score += 10000;
  }
  score += (r1 > r2 ? r1 : r2) * 4;
  return score;
}

class _IsoGroup {
  final String emoji;
  final bool isSpecial;
  const _IsoGroup(this.emoji, {this.isSpecial = false});
}

List<_IsoGroup> _scanMatchGroups(
  List<List<String>> g,
  int rows,
  int cols,
  Set<String> unmatchable,
) {
  final groups = <_IsoGroup>[];
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
        groups.add(_IsoGroup(h.emoji, isSpecial: true));
        foundIntersect = true;
        break;
      }
    }
    if (!foundIntersect) groups.add(_IsoGroup(h.emoji));
  }

  for (final v in vRuns) {
    final alreadyCovered = groups.any(
      (grp) => grp.isSpecial && grp.emoji == v.emoji,
    );
    if (!alreadyCovered) groups.add(_IsoGroup(v.emoji));
  }

  return groups;
}
