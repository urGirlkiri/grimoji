import 'package:grimoji/features/match/models/iso_group.dart';
import 'package:grimoji/config/emojis/index.dart';

List<IsoGroup> scanMatchGroups(
  List<List<String>> g,
  int rows,
  int cols,
  Set<String> unmatchable,
) {
  final groups = <IsoGroup>[];
  final hRuns = <({String emoji, int row, int startCol, int len})>[];
  final vRuns = <({String emoji, int col, int startRow, int len})>[];

  for (int r = 0; r < rows; r++) {
    int streak = 1;
    for (int c = 1; c <= cols; c++) {
      final same =
          c < cols && g[r][c] == g[r][c - 1] && !unmatchable.contains(g[r][c]);
      if (!same) {
        if (streak >= 3) {
          hRuns.add((
            emoji: g[r][c - 1],
            row: r,
            startCol: c - streak,
            len: streak,
          ));
        }
        streak = 1;
      } else {
        streak++;
      }
    }
  }

  for (int c = 0; c < cols; c++) {
    int streak = 1;
    for (int r = 1; r <= rows; r++) {
      final same =
          r < rows && g[r][c] == g[r - 1][c] && !unmatchable.contains(g[r][c]);
      if (!same) {
        if (streak >= 3) {
          vRuns.add((
            emoji: g[r - 1][c],
            col: c,
            startRow: r - streak,
            len: streak,
          ));
        }
        streak = 1;
      } else {
        streak++;
      }
    }
  }

  for (final h in hRuns) {
    bool foundIntersect = false;
    for (final v in vRuns) {
      if (h.emoji != v.emoji) continue;
      final hCols = List.generate(h.len, (i) => h.startCol + i).toSet();
      final vRows = List.generate(v.len, (i) => v.startRow + i).toSet();
      if (hCols.contains(v.col) && vRows.contains(h.row)) {
        final totalSize = h.len + v.len - 1;

        String? yieldEmoji;
        if (totalSize >= 5) {
          yieldEmoji = Emojis.bomb.visual;
        } else {
          yieldEmoji = Emojis.ghost.visual;
        }
        groups.add(
          IsoGroup(
            h.emoji,
            isSpecial: true,
            size: totalSize,
            yieldEmoji: yieldEmoji,
          ),
        );
        foundIntersect = true;
        break;
      }
    }
    if (!foundIntersect) {
      groups.add(IsoGroup(h.emoji, size: h.len));
    }
  }

  for (final v in vRuns) {
    final alreadyCovered = groups.any(
      (grp) => grp.isSpecial && grp.emoji == v.emoji,
    );
    if (!alreadyCovered) {
      String? yieldEmoji;
      if (v.len >= 5) {
        yieldEmoji = Emojis.hole.visual;
      }
      groups.add(IsoGroup(v.emoji, size: v.len, yieldEmoji: yieldEmoji));
    }
  }

  return groups;
}
