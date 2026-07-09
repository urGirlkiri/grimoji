import 'package:grimoji/features/match/detectors/threat/models/threat_scan.dart';
import 'package:grimoji/features/match/detectors/threat/scorer.dart';

List<int>? isolate(ThreatScan args) {
  final int rows = args.rows;
  final int cols = args.cols;
  final List<List<String>> board = args.gridVisuals;

  final intrusiveTarget = _findTopmostLeftmostIntrusive(
    board,
    rows,
    cols,
    args.intrusiveVisuals,
  );
  if (intrusiveTarget != null) return intrusiveTarget;

  final List<({List<int> coordinates, int threatScore})> potentialTargets = [];

  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      final threatScore = scoreThreatTarget(
        board,
        row,
        col,
        rows,
        cols,
        args.unmatchableVisuals,
        args.targetVisual,
        args.targetIngredients,
      );

      potentialTargets.add((coordinates: [row, col], threatScore: threatScore));
    }
  }

  if (potentialTargets.isEmpty) return null;

  potentialTargets.sort((a, b) => b.threatScore.compareTo(a.threatScore));
  final int topScore = potentialTargets.first.threatScore;

  final bestOptions =
      potentialTargets
          .where((target) => target.threatScore == topScore)
          .toList()
        ..shuffle();
  return bestOptions.first.coordinates;
}

List<int>? _findTopmostLeftmostIntrusive(
  List<List<String>> board,
  int rows,
  int cols,
  Set<String> intrusiveVisuals,
) {
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      if (intrusiveVisuals.contains(board[row][col])) {
        return [row, col];
      }
    }
  }
  return null;
}
