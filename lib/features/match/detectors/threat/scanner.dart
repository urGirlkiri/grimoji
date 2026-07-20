List<List<String>> simulateBoardAfterGhostImpact(
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

int countMatches(
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

int countNearMisses(
  List<List<String>> board,
  int rows,
  int cols,
  Set<String> unmatchable,
) {
  int nearMissesFound = 0;

  for (int row = 0; row < rows; row++) {
    int streak = 1;
    for (int col = 1; col <= cols; col++) {
      final isMatchingNeighbor =
          col < cols &&
          board[row][col].isNotEmpty &&
          board[row][col] == board[row][col - 1] &&
          !unmatchable.contains(board[row][col]);

      if (!isMatchingNeighbor) {
        if (streak == 2) nearMissesFound++;
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
        if (streak == 2) nearMissesFound++;
        streak = 1;
      } else {
        streak++;
      }
    }
  }
  return nearMissesFound;
}

int countRecipeChainNearMisses(
  List<List<String>> board,
  int rows,
  int cols,
  Set<String> unmatchable,
  Map<String, int> recipeChainSteps,
) {
  int nearMissesFound = 0;

  for (int row = 0; row < rows; row++) {
    int streak = 1;
    for (int col = 1; col <= cols; col++) {
      final isMatchingNeighbor =
          col < cols &&
          board[row][col].isNotEmpty &&
          board[row][col] == board[row][col - 1] &&
          !unmatchable.contains(board[row][col]);

      if (!isMatchingNeighbor) {
        if (streak == 2 && recipeChainSteps.containsKey(board[row][col - 1])) {
          nearMissesFound++;
        }
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
        if (streak == 2 && recipeChainSteps.containsKey(board[row - 1][col])) {
          nearMissesFound++;
        }
        streak = 1;
      } else {
        streak++;
      }
    }
  }

  return nearMissesFound;
}
