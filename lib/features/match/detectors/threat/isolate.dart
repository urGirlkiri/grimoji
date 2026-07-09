import 'package:grimoji/features/match/detectors/threat/models/threat_scan.dart';
import 'package:grimoji/features/match/detectors/threat/scorer.dart';

List<int>? isolate(ThreatScan args) {
  final int rows = args.rows;
  final int cols = args.cols;
  final List<List<String>> board = args.gridVisuals;

  final List<({List<int> coordinates, int threatScore})> potentialTargets = [];

  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      final threatScore = scoreThreatTarget(
        board,
        row,
        col,
        rows,
        cols,
        args.intrusiveVisuals,
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
