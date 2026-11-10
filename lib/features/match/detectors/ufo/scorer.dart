import 'package:grimoji/features/alchemy/behavior_register.dart';
import 'package:grimoji/features/alchemy/reactions/models/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/match/detectors/threat/scanner.dart';
import 'package:grimoji/features/match/detectors/ufo/scanner.dart';
import 'package:grimoji/features/match/models/tile.dart';

const int matchWeight = 100;
const int nearMissWeight = 15;

const int deadTileBonus = 40;
const int blockerBonus = 25;

const int abductPowerupPenalty = 60;

const int chainStepPenalty = 15;

const int reactionAdjacencyBonus = 50;

const int specialAdjacencyBonus = 30;

int _simDelta(
  List<List<String>> before,
  List<List<String>> after,
  int rows,
  int cols,
  Set<String> unmatchableVisuals,
) {
  final matchesBefore = countMatches(before, rows, cols, unmatchableVisuals);
  final matchesAfter = countMatches(after, rows, cols, unmatchableVisuals);
  final nearMissesBefore = countNearMisses(
    before,
    rows,
    cols,
    unmatchableVisuals,
  );
  final nearMissesAfter = countNearMisses(
    after,
    rows,
    cols,
    unmatchableVisuals,
  );

  return ((matchesAfter - matchesBefore) * matchWeight) +
      ((nearMissesAfter - nearMissesBefore) * nearMissWeight);
}

List<List<String>> _visualGrid(List<List<Tile>> grid) {
  return grid
      .map(
        (row) =>
            row.map((tile) => (tile.morphTarget ?? tile.emoji).visual).toList(),
      )
      .toList();
}

int _chainPenalty(String visual, Map<String, int> recipeChainSteps) {
  final step = recipeChainSteps[visual];
  return step == null ? 0 : step * chainStepPenalty;
}

int scoreAbductCandidate(
  List<List<Tile>> grid, {
  required int row,
  required int col,
  required String targetVisual,
  required Set<String> unmatchableVisuals,
  required Map<String, int> recipeChainSteps,
}) {
  final rows = grid.length;
  final cols = grid[0].length;
  final tile = grid[row][col];
  final displayEmoji = tile.morphTarget ?? tile.emoji;
  final visual = displayEmoji.visual;

  final visualGrid = _visualGrid(grid);
  final collapsed = collapseColumnAfterRemoval(visualGrid, row: row, col: col);

  var score = _simDelta(visualGrid, collapsed, rows, cols, unmatchableVisuals);

  if (unmatchableVisuals.contains(visual) && recipeChainSteps[visual] == null) {
    score += deadTileBonus;
  }

  var targetAlignments = 0;
  for (int r = 0; r < rows; r++) {
    if (visualGrid[r][col] == targetVisual) targetAlignments++;
  }
  score += targetAlignments * blockerBonus;

  if (tile.isCollectiblePowerup) score -= abductPowerupPenalty;
  score -= _chainPenalty(visual, recipeChainSteps);

  return score;
}

int scoreExplosiveCandidate(
  List<List<Tile>> grid, {
  required int row,
  required int col,
  required String targetVisual,
  required Set<String> unmatchableVisuals,
  required Map<String, int> recipeChainSteps,
}) {
  final rows = grid.length;
  final cols = grid[0].length;
  final tile = grid[row][col];
  final displayEmoji = tile.morphTarget ?? tile.emoji;
  final visual = displayEmoji.visual;

  final visualGrid = _visualGrid(grid);
  final collapsed = collapseColumnAfterRemoval(visualGrid, row: row, col: col);

  var score = _simDelta(visualGrid, collapsed, rows, cols, unmatchableVisuals);

  final intrusiveVisuals = BehaviorRegister.intrusiveEmojis
      .map((emoji) => emoji.visual)
      .toSet();

  for (final (dr, dc) in const [(0, 1), (0, -1), (1, 0), (-1, 0)]) {
    final nr = row + dr;
    final nc = col + dc;
    if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) continue;

    final neighborEmoji = grid[nr][nc].morphTarget ?? grid[nr][nc].emoji;
    final neighborReaction = RecipeBook.getReactionFor(neighborEmoji);
    if (neighborReaction != null &&
        neighborReaction.type == ReactionType.explosive) {
      score += reactionAdjacencyBonus;
    }
    if (intrusiveVisuals.contains(neighborEmoji.visual)) {
      score += specialAdjacencyBonus;
    }
  }

  if (tile.isCollectiblePowerup) score -= abductPowerupPenalty ~/ 2;
  score -= _chainPenalty(visual, recipeChainSteps);

  return score;
}
