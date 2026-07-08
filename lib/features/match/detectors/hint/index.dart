
import 'package:flutter/foundation.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/detectors/hint/isolate.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/models/hint_scan_args.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/utils/manager.dart';
import 'package:grimoji/features/match/detectors/match.dart';

class HintDetector {
  static Future<List<TileCoordinate>?> findBestMove({
    required List<List<Tile>> grid,
    required GameEmoji targetEmoji,
  }) async {
    final gridSnapshot = grid
        .map((row) => row.map((t) => t.emoji.visual).toList())
        .toList();
    final hasBehaviorGrid = grid
        .map((row) => row.map((t) => t.behavior != null).toList())
        .toList();
    final targetIngredients = RecipeBook.allRecipes
        .where((r) => r.yields == targetEmoji)
        .map((r) => r.ingredient.visual)
        .toSet();
    final unmatchableVisuals = MatchDetector.unmatchableEmojis
        .map((e) => e.visual)
        .toSet();

    final result = await compute(
      isolate,
      HintScanArgs(
        gridVisuals: gridSnapshot,
        hasBehavior: hasBehaviorGrid,
        rows: BoardManager.rows,
        cols: BoardManager.cols,
        targetVisual: targetEmoji.visual,
        targetIngredients: targetIngredients,
        unmatchableVisuals: unmatchableVisuals,
      ),
    );

    if (result == null) return null;
    return [
      TileCoordinate(row: result[0], col: result[1]),
      TileCoordinate(row: result[2], col: result[3]),
      TileCoordinate(row: result[4], col: result[5]),
    ];
  }
}
