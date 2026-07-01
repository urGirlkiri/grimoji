import 'package:flutter/foundation.dart';
import 'package:grimoji/features/alchemy/behavior_register.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
import 'package:grimoji/features/match/board/utils/manager.dart';
import 'package:grimoji/features/match/utils/match_detector.dart';
import 'package:grimoji/config/emojis/index.dart';

class GhostEvaluator {
  static Future<TileCoordinate?> findTarget({
    required List<List<Tile>> grid,
    required GameEmoji targetEmoji,
  }) async {
    final gridVisuals = grid
        .map((row) => row.map((tile) => tile.emoji.visual).toList())
        .toList();

    final gridBehaviors = grid
        .map((row) => row.map((tile) => tile.behavior != null).toList())
        .toList();

    final intrusiveEnemies = BehaviorRegister.intrusiveEmojis
        .map((emoji) => emoji.visual)
        .toSet();

    final solidObstacles = MatchDetector.unmatchableEmojis
        .map((emoji) => emoji.visual)
        .toSet();

    final ingredientsForLevelGoal = RecipeBook.allRecipes
        .where((recipe) => recipe.yields == targetEmoji)
        .map((recipe) => recipe.ingredient.visual)
        .toSet();

    final targetCoordinates = await compute(
      _evaluateBoardForBestTarget,
      _GhostScanArgs(
        gridVisuals: gridVisuals,
        hasBehavior: gridBehaviors,
        rows: BoardManager.rows,
        cols: BoardManager.cols,
        intrusiveVisuals: intrusiveEnemies,
        unmatchableVisuals: solidObstacles,
        targetVisual: targetEmoji.visual,
        targetIngredients: ingredientsForLevelGoal,
      ),
    );

    if (targetCoordinates == null) return null;
    return TileCoordinate(row: targetCoordinates[0], col: targetCoordinates[1]);
  }
}

class _GhostScanArgs {
  final List<List<String>> gridVisuals;
  final List<List<bool>> hasBehavior;
  final int rows;
  final int cols;
  final Set<String> intrusiveVisuals;
  final Set<String> unmatchableVisuals;
  final String targetVisual;
  final Set<String> targetIngredients;

  _GhostScanArgs({
    required this.gridVisuals,
    required this.hasBehavior,
    required this.rows,
    required this.cols,
    required this.intrusiveVisuals,
    required this.unmatchableVisuals,
    required this.targetVisual,
    required this.targetIngredients,
  });
}

List<int>? _evaluateBoardForBestTarget(_GhostScanArgs args) {
  final int rows = args.rows;
  final int cols = args.cols;
  final List<List<String>> board = args.gridVisuals;

  final List<({List<int> coordinates, int threatScore})> potentialTargets = [];

  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      final String currentVisual = board[row][col];
      final bool hasActiveBehavior = args.hasBehavior[row][col];

      int threatScore = 0;

      if (args.intrusiveVisuals.contains(currentVisual)) {
        threatScore += 300;
      } else if (hasActiveBehavior) {
        threatScore += 100;
      } else if (args.unmatchableVisuals.contains(currentVisual)) {
        threatScore += 150;
      } else {
        final simulatedBoard = _simulateBoardAfterGhostImpact(
          board,
          row,
          col,
          rows,
          cols,
        );
        final predictedMatches = _countMatches(
          simulatedBoard,
          rows,
          cols,
          args.unmatchableVisuals,
        );

        threatScore += (predictedMatches * 50);

        if (args.targetIngredients.contains(currentVisual)) threatScore += 50;

        if (_willDropCreateLevelGoal(
          simulatedBoard,
          rows,
          cols,
          args.targetVisual,
          args.unmatchableVisuals,
        )) {
          threatScore += 100;
        }
      }

      threatScore += row;

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

List<List<String>> _simulateBoardAfterGhostImpact(
  List<List<String>> currentBoard,
  int impactRow,
  int impactCol,
  int totalRows,
  int totalCols,
) {
  final simulatedBoard = List.generate(
    totalRows,
    (r) => List<String>.from(currentBoard[r]),
  );

  for (int row = impactRow; row > 0; row--) {
    simulatedBoard[row][impactCol] = simulatedBoard[row - 1][impactCol];
  }
  simulatedBoard[0][impactCol] = '';
  return simulatedBoard;
}

int _countMatches(
  List<List<String>> board,
  int rows,
  int cols,
  Set<String> unmatchable,
) {
  int totalMatchesFound = 0;

  for (int row = 0; row < rows; row++) {
    int streak = 1;
    for (int col = 1; col <= cols; col++) {
      final isMatchingNeighbor =
          col < cols &&
          board[row][col].isNotEmpty &&
          board[row][col] == board[row][col - 1] &&
          !unmatchable.contains(board[row][col]);

      if (!isMatchingNeighbor) {
        if (streak >= 3) totalMatchesFound++;
        streak = 1;
      } else {
        streak++;
      }
    }
  }

  for (int col = 0; col < cols; col++) {
    int streak = 1;
    for (int row = 1; row <= rows; row++) {
      final isMatchingNeighbor =
          row < rows &&
          board[row][col].isNotEmpty &&
          board[row][col] == board[row - 1][col] &&
          !unmatchable.contains(board[row][col]);

      if (!isMatchingNeighbor) {
        if (streak >= 3) totalMatchesFound++;
        streak = 1;
      } else {
        streak++;
      }
    }
  }
  return totalMatchesFound;
}

bool _willDropCreateLevelGoal(
  List<List<String>> board,
  int rows,
  int cols,
  String targetVisual,
  Set<String> unmatchable,
) {
  for (int row = 0; row < rows; row++) {
    int streak = 1;
    for (int col = 1; col <= cols; col++) {
      final isMatchingNeighbor =
          col < cols &&
          board[row][col].isNotEmpty &&
          board[row][col] == board[row][col - 1] &&
          !unmatchable.contains(board[row][col]);

      if (!isMatchingNeighbor) {
        if (streak >= 3 && board[row][col - 1] == targetVisual) return true;
        streak = 1;
      } else {
        streak++;
      }
    }
  }
  for (int col = 0; col < cols; col++) {
    int streak = 1;
    for (int row = 1; row <= rows; row++) {
      final isMatchingNeighbor =
          row < rows &&
          board[row][col].isNotEmpty &&
          board[row][col] == board[row - 1][col] &&
          !unmatchable.contains(board[row][col]);

      if (!isMatchingNeighbor) {
        if (streak >= 3 && board[row - 1][col] == targetVisual) return true;
        streak = 1;
      } else {
        streak++;
      }
    }
  }
  return false;
}
