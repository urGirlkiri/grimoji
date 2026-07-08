import 'dart:math';
import 'package:grimoji/features/match/detectors/hint/completing.dart';
import 'package:grimoji/features/match/detectors/hint/scorer.dart';
import 'package:grimoji/features/match/models/hint_scan_args.dart';

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
    best.sort((a, b) {
      final aMaxRow = max(a.coords[0], a.coords[2]);
      final bMaxRow = max(b.coords[0], b.coords[2]);
      final cmp = bMaxRow.compareTo(aMaxRow);
      if (cmp != 0) return cmp;
      return b.coords[0].compareTo(a.coords[0]);
    });
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
