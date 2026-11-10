List<List<String>> collapseColumnAfterRemoval(
  List<List<String>> board, {
  required int row,
  required int col,
}) {
  final simulated = List.generate(
    board.length,
    (r) => List<String>.from(board[r]),
  );

  for (int r = row; r > 0; r--) {
    simulated[r][col] = simulated[r - 1][col];
  }
  simulated[0][col] = '';

  return simulated;
}
