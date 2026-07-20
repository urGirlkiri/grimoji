import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/match/detectors/threat/scores.dart';
import 'package:grimoji/features/match/detectors/threat/scanner.dart';
import 'package:grimoji/features/match/detectors/hint/scanner.dart' as hint;
import 'package:grimoji/features/match/models/iso_group.dart';

int scoreThreatTarget(
  List<List<String>> board,
  int row,
  int col,
  int rows,
  int cols,
  Set<String> unmatchableVisuals,
  Set<String> obstacleVisuals,
  String targetVisual,
  Map<String, int> recipeChainSteps,
) {
  final String currentVisual = board[row][col];
  int threatScore = 0;

  if (unmatchableVisuals.contains(currentVisual)) {
    threatScore += unmatchableObstacleScore;
  } else if (obstacleVisuals.contains(currentVisual)) {
    threatScore += obstacleScore;
  } else {
    final currentStep = recipeChainSteps[currentVisual];
    if (currentStep != null) {
      threatScore += (chainTileScore / (currentStep + 1)).toInt();
    }

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

    final matchedGroups = hint.scanMatchGroups(
      simulatedBoard,
      rows,
      cols,
      unmatchableVisuals,
    );

    for (final group in matchedGroups) {
      final productVisual = _matchYieldVisual(group);

      if (productVisual == targetVisual) {
        threatScore += targetScore.toInt();
      } else {
        final step = recipeChainSteps[productVisual];
        if (step != null) {
          threatScore += (chainMatchScore / (step + 1)).toInt();
        }
      }
    }

    final pathNearMisses = countRecipeChainNearMisses(
      simulatedBoard,
      rows,
      cols,
      unmatchableVisuals,
      recipeChainSteps,
    );
    threatScore += (pathNearMisses * nearMissBonus).toInt();
  }

  threatScore += row;

  return threatScore;
}

String _matchYieldVisual(IsoGroup group) {
  if (group.isSpecial && group.yieldEmoji != null) {
    return group.yieldEmoji!;
  }

  final emoji = RecipeBook.emojiForVisual(group.emoji);
  if (emoji == null) return group.emoji;

  final yield = RecipeBook.getRecipeYield(emoji, group.size);
  return yield?.visual ?? group.emoji;
}
