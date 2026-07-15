import 'package:flutter/foundation.dart';
import 'package:grimoji/features/alchemy/behavior_register.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/detectors/match.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/detectors/threat/isolate.dart';
import 'package:grimoji/features/match/detectors/threat/models/threat_scan.dart';

class ThreatDetector {
  static Future<TileCoordinate?> findTarget({
    required List<List<Tile>> grid,
    required GameEmoji targetEmoji,
    Set<TileCoordinate> excluded = const {},
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

    final obstacleVisuals = {Emojis.poop.visual};

    final ingredientsForLevelGoal = RecipeBook.allRecipes
        .where((recipe) => recipe.yields == targetEmoji)
        .map((recipe) => recipe.ingredient.visual)
        .toSet();

    final excludedPositions = excluded
        .map((coord) => '${coord.row},${coord.col}')
        .toSet();

    final targetCoordinates = await compute(
      isolate,
      ThreatScan(
        gridVisuals: gridVisuals,
        hasBehavior: gridBehaviors,
        rows: BoardManager.rows,
        cols: BoardManager.cols,
        intrusiveVisuals: intrusiveEnemies,
        unmatchableVisuals: solidObstacles,
        obstacleVisuals: obstacleVisuals,
        targetVisual: targetEmoji.visual,
        targetIngredients: ingredientsForLevelGoal,
        excludedPositions: excludedPositions,
      ),
    );

    if (targetCoordinates == null) return null;
    return TileCoordinate(row: targetCoordinates[0], col: targetCoordinates[1]);
  }
}
