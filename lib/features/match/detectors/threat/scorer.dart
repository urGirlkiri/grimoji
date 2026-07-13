import 'package:grimoji/features/match/detectors/threat/scores.dart';
import 'package:grimoji/features/match/detectors/threat/scanner.dart';

int scoreThreatTarget(
  List<List<String>> board,
  int row,
  int col,
  int rows,
  int cols,
  Set<String> unmatchableVisuals,
  Set<String> obstacleVisuals,
  String targetVisual,
  Set<String> targetIngredients,
) {
  final String currentVisual = board[row][col];
  int threatScore = 0;

  if (unmatchableVisuals.contains(currentVisual)) {
    threatScore += unmatchableObstacleScore;
  } else if (obstacleVisuals.contains(currentVisual)) {
    threatScore += obstacleScore;
  } else {
    final simulatedBoard = simulateBoardAfterGhostImpact(
      board,
      row,
      col,
      rows,
      cols,
    );
    final predictedMatches = countMatches(
      simulatedBoard,
      rows,
      cols,
      unmatchableVisuals,
    );

    final nearMisses = countNearMisses(
      simulatedBoard,
      rows,
      cols,
      unmatchableVisuals,
    );

    threatScore += (predictedMatches * matchScoreMultiplier);
    threatScore += (nearMisses * nearMissScoreMultiplier).toInt();

    if (targetIngredients.contains(currentVisual)) {
      threatScore += targetIngredientScore;
      if (nearMisses > 0) threatScore += targetIngredientNearMissBonus;
    }

    if (willDropCreateLevelGoal(
      simulatedBoard,
      rows,
      cols,
      targetVisual,
      unmatchableVisuals,
    )) {
      threatScore += levelGoalDropScore;
    }
  }

  threatScore += row;

  return threatScore;
}
