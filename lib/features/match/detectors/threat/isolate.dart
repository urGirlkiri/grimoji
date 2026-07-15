import 'package:grimoji/features/match/detectors/threat/models/threat_scan.dart';
import 'package:grimoji/features/match/detectors/threat/scorer.dart';

List<int>? isolate(ThreatScan args) {
  final int rows = args.rows;
  final int cols = args.cols;
  final List<List<String>> board = args.gridVisuals;
  final excluded = args.excludedPositions;

  final intrusiveTarget = _findTopmostLeftmostIntrusive(
    board,
    rows,
    cols,
    args.intrusiveVisuals,
    excluded,
  );
  if (intrusiveTarget != null) return intrusiveTarget;

  final obstacleTarget = _findTopmostLeftmostObstacle(
    board,
    rows,
    cols,
    args.obstacleVisuals,
    excluded,
  );
  if (obstacleTarget != null) return obstacleTarget;

  final List<({List<int> coordinates, int threatScore})> potentialTargets = [];

  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      if (excluded.contains('$row,$col')) continue;

      final threatScore = scoreThreatTarget(
        board,
        row,
        col,
        rows,
        cols,
        args.unmatchableVisuals,
        args.obstacleVisuals,
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
  Set<String> excluded,
) {
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      if (excluded.contains('$row,$col')) continue;
      if (intrusiveVisuals.contains(board[row][col])) {
        return [row, col];
      }
    }
  }
  return null;
}

List<int>? _findTopmostLeftmostObstacle(
  List<List<String>> board,
  int rows,
  int cols,
  Set<String> obstacleVisuals,
  Set<String> excluded,
) {
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      if (excluded.contains('$row,$col')) continue;
      if (obstacleVisuals.contains(board[row][col])) {
        return [row, col];
      }
    }
  }
  return null;
}
