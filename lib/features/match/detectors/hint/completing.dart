(int, int) findCompletingTile(
  List<List<String>> g,
  int r1,
  int c1,
  int r2,
  int c2,
  int rows,
  int cols,
  Set<String> unmatchable,
) {
  final tmp = g[r1][c1];
  g[r1][c1] = g[r2][c2];
  g[r2][c2] = tmp;

  final matchedCells = <(int, int)>{};

  for (int r = 0; r < rows; r++) {
    int start = 0;

    while (start < cols) {
      int end = start + 1;

      while (end < cols &&
          g[r][end] == g[r][start] &&
          !unmatchable.contains(g[r][start])) {
        end++;
      }

      if (end - start >= 3) {
        for (int c = start; c < end; c++) {
          matchedCells.add((r, c));
        }
      }

      start = end;
    }
  }

  for (int c = 0; c < cols; c++) {
    int start = 0;

    while (start < rows) {
      int end = start + 1;

      while (end < rows &&
          g[end][c] == g[start][c] &&
          !unmatchable.contains(g[start][c])) {
        end++;
      }

      if (end - start >= 3) {
        for (int r = start; r < end; r++) {
          matchedCells.add((r, c));
        }
      }

      start = end;
    }
  }

  g[r2][c2] = g[r1][c1];
  g[r1][c1] = tmp;

  final position1Matched = matchedCells.contains((r1, c1));
  final position2Matched = matchedCells.contains((r2, c2));

  if (position1Matched && !position2Matched) {
    return (r2, c2);
  }

  if (position2Matched && !position1Matched) {
    return (r1, c1);
  }

  return (r2, c2);
}
