import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/match/models/hint_scan_args.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/models/iso_group.dart';
import 'package:grimoji/features/match/detectors/hint/scores.dart';
import 'package:grimoji/features/match/detectors/hint/scanner.dart';

int? scoreHintMove(
  List<List<String>> g,
  int r1,
  int c1,
  int r2,
  int c2,
  int rows,
  int cols,
  HintScanArgs args,
  Set<String> unmatchable,
) {
  final tmp = g[r1][c1];
  g[r1][c1] = g[r2][c2];
  g[r2][c2] = tmp;

  final matched = scanMatchGroups(g, rows, cols, unmatchable);

  g[r2][c2] = g[r1][c1];
  g[r1][c1] = tmp;

  if (matched.isEmpty) return null;

  int score = baseScore;

  final totalMatchSize = matched.fold<int>(0, (sum, group) => sum + group.size);

  score += (totalMatchSize - 3) * matchSizeBonus;

  if (matched.any((m) => m.isSpecial)) {
    score += specialMatchBonus;
  }

  for (final group in matched) {
    final yield = _matchGroupYield(group);

    if (yield == Emojis.ghost.visual) {
      score += ghostYieldBonus;
    } else if (yield == Emojis.bomb.visual) {
      score += bombYieldBonus;
    } else if (yield == Emojis.hole.visual) {
      score += holeYieldBonus;
    }

    if (yield == args.targetVisual) {
      score += targetScore.toInt();
      final targetRows = <int>[];
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) {
          if (g[r][c] == args.targetVisual) {
            targetRows.add(r);
          }
        }
      }
      if (targetRows.isNotEmpty) {
        final avgTargetRow =
            targetRows.reduce((a, b) => a + b) / targetRows.length;
        final swapAvgRow = (r1 + r2) / 2;
        final distance = (swapAvgRow - avgTargetRow).abs();
        score -= (distance * 10000000).toInt();
      }
    } else {
      final step = args.recipeChainSteps[yield];
      if (step != null) {
        score += chainMatchBonus ~/ (step + 1);
      }
    }
  }

  for (final visual in {g[r1][c1], g[r2][c2]}) {
    final step = args.recipeChainSteps[visual];
    if (step != null) {
      score += chainTileBonus ~/ (step + 1);
    }
  }

  return score;
}

String _matchGroupYield(IsoGroup group) {
  if (group.isSpecial && group.yieldEmoji != null) {
    return group.yieldEmoji!;
  }

  final emoji = RecipeBook.emojiForVisual(group.emoji);
  if (emoji == null) return group.emoji;

  final yield = RecipeBook.getRecipeYield(emoji, group.size);
  return yield?.visual ?? group.emoji;
}
