import 'package:flutter/foundation.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/behavior_register.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
import 'package:grimoji/features/match/board/utils/manager.dart';
import 'package:grimoji/features/match/model/cascade_step_result.dart';
import 'package:grimoji/features/match/model/detonation_step_result.dart';
import 'package:grimoji/features/match/utils/swipe_detector.dart';
import 'package:grimoji/features/match/utils/match_detector.dart';
import 'alchemy_engine.dart';
import 'behavior_engine.dart';

class GameEngine {
  final GameLevel level;
  final BoardManager boardManager;
  final void Function(SfxType) playSfx;

  late final AlchemyEngine _alchemy;
  late final BehaviorEngine _behavior;

  GameEngine({
    required this.level,
    required this.boardManager,
    required this.playSfx,
  }) {
    _behavior = BehaviorEngine(
      level: level,
      boardManager: boardManager,
      getBehavior: BehaviorRegister.getBehaviorFor,
    );

    _alchemy = AlchemyEngine(
      boardManager: boardManager,
      playSfx: playSfx,
      getRecipes: RecipeBook.getRecipesFor,
      getReactionFor: RecipeBook.getReactionFor,
      getTransformationsForType: RecipeBook.getTransformationsForType,
      getAoERadiusForType: RecipeBook.getAoERadiusForType,
      initializeBehavior: _behavior.initializeBehavior,
      onTileBlasted: _behavior.processBlastBehavior,
      onTileMatched: _behavior.processMatchedBehavior,
    );
  }

  List<List<Tile>> get grid => boardManager.gridTiles;

  void initialize() {
    RecipeBook.initialize();
    boardManager.initialize();
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        _behavior.initializeBehavior(grid[r][c]);
      }
    }
  }

  SwipeDecision evaluateSwipe(TileCoordinate dCoord, TileCoordinate tCoord) {
    final decision = SwipeDetector.evaluate(
      grid: grid,
      dCoord: dCoord,
      tCoord: tCoord,
      getSwipeBehaviors: _behavior.processSwipedWithBehavior,
      hasSwipeBehavior: _behavior.hasSwipeBehavior,
    );

    if (decision.type != SwipeResult.invalid) {
      boardManager.swapTiles(dCoord, tCoord);
    }
    return decision;
  }

  CascadeStepResult processCascadeStep({
    required List<MatchGroup> matchedGroups,
    required TileCoordinate targetCoordinate,
    required bool isFirstMatch,
  }) {
    return _alchemy.processCascadeStep(
      matchedGroups: matchedGroups,
      targetCoordinate: targetCoordinate,
      isFirstMatch: isFirstMatch,
    );
  }

  DetonationStepResult processDetonationStep() {
    return _alchemy.processDetonationStep();
  }

  void categorizeAnimations(
    List<MatchGroup> matchedGroups,
    bool isFirstMatch,
    TileCoordinate targetCoord,
  ) {
    for (var groupMatch in matchedGroups) {
      if (groupMatch.isSpecial) {
        _categorizeShapeAnim(groupMatch, isFirstMatch ? targetCoord : null);
        continue;
      }

      final recipes = RecipeBook.getRecipesFor(groupMatch.emoji);
      final reaction = RecipeBook.getReactionFor(groupMatch.emoji);

      bool mergeHappened = false;

      if (recipes != null) {
        recipes.sort((a, b) => b.requiredAmount.compareTo(a.requiredAmount));

        for (var recipe in recipes) {
          if (groupMatch.coordinates.length >= recipe.requiredAmount) {
            mergeHappened = true;
            TileCoordinate catalyst =
                (isFirstMatch && groupMatch.coordinates.contains(targetCoord))
                ? targetCoord
                : groupMatch.coordinates.first;

            for (var coord in groupMatch.coordinates) {
              final tile = grid[coord.row][coord.col];
              tile.isMergePoint = coord == catalyst;

              if (!tile.isMergePoint) {
                tile.isMerging = true;
                tile.coordinate.col = catalyst.col;
                tile.coordinate.row = catalyst.row;
              } else {
                tile.morphTarget = recipe.yields;
              }
            }

            break;
          }
        }
      }

      if (!mergeHappened) {
        if (reaction?.type == ReactionType.explosive) {
          continue;
        } else {
          for (var coord in groupMatch.coordinates) {
            grid[coord.row][coord.col].isExploding = true;
            playSfx(SfxType.explode);
          }
        }
      } else {
        playSfx(SfxType.merge);
      }
    }
  }

  void _categorizeShapeAnim(MatchGroup group, TileCoordinate? targetCoord) {
    final catalyst = MatchDetector.resolveShapePivot(
      group,
      swipeTarget: targetCoord,
    );

    for (var coord in group.coordinates) {
      final tile = grid[coord.row][coord.col];
      tile.isMergePoint = coord == catalyst;

      if (!tile.isMergePoint) {
        tile.isMerging = true;
        tile.coordinate.col = catalyst.col;
        tile.coordinate.row = catalyst.row;
      } else {
        tile.morphTarget = group.yields;
      }
    }
    playSfx(SfxType.merge);
  }

  void shuffleGrid() {
    bool validBoard = false;
    int attempts = 0;
    const maxAttempts = 50;

    while (!validBoard && attempts < maxAttempts) {
      boardManager.shuffleGrid();

      final immediateMatches = MatchDetector.findMatchedGroups(grid);
      if (immediateMatches.isNotEmpty) {
        attempts++;
        continue;
      }

      validBoard = hasPossibleMoves();
      attempts++;
    }

    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        _behavior.initializeBehavior(grid[r][c]);
      }
    }
  }

  bool hasPossibleMoves() {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        if (c < BoardManager.cols - 1) {
          final d = SwipeDetector.evaluate(
            grid: grid,
            dCoord: TileCoordinate(row: r, col: c),
            tCoord: TileCoordinate(row: r, col: c + 1),
            getSwipeBehaviors: _behavior.processSwipedWithBehavior,
            hasSwipeBehavior: _behavior.hasSwipeBehavior,
            quickCheckOnly: true,
          );
          if (d.type != SwipeResult.invalid) return true;
        }
        if (r < BoardManager.rows - 1) {
          final d = SwipeDetector.evaluate(
            grid: grid,
            dCoord: TileCoordinate(row: r, col: c),
            tCoord: TileCoordinate(row: r + 1, col: c),
            getSwipeBehaviors: _behavior.processSwipedWithBehavior,
            hasSwipeBehavior: _behavior.hasSwipeBehavior,
            quickCheckOnly: true,
          );
          if (d.type != SwipeResult.invalid) return true;
        }
      }
    }
    return false;
  }

  Future<List<TileCoordinate>?> getHintMove() async {
    final gridSnapshot = grid
        .map((row) => row.map((t) => t.emoji.visual).toList())
        .toList();
    final hasBehaviorGrid = grid
        .map((row) => row.map((t) => t.behavior != null).toList())
        .toList();
    final targetVisual = level.targetEmoji.visual;
    final targetIngredients = RecipeBook.allRecipes
        .where((r) => r.yields == level.targetEmoji)
        .map((r) => r.ingredient.visual)
        .toSet();
    final unmatchableVisuals = MatchDetector.unmatchableEmojis
        .map((e) => e.visual)
        .toSet();

    final result = await compute(
      _hintScanIsolate,
      _HintScanArgs(
        gridVisuals: gridSnapshot,
        hasBehavior: hasBehaviorGrid,
        rows: BoardManager.rows,
        cols: BoardManager.cols,
        targetVisual: targetVisual,
        targetIngredients: targetIngredients,
        unmatchableVisuals: unmatchableVisuals,
      ),
    );

    if (result == null) return null;
    return [
      TileCoordinate(row: result[0], col: result[1]),
      TileCoordinate(row: result[2], col: result[3]),
    ];
  }

  void processTurnEndBehaviors() => _behavior.processTurnEndBehaviors();

  void executeBehaviorActions(List<BehaviorAction> actions, int row, int col) {
    _behavior.executeBehaviorActions(actions, row, col);
  }

  List<BehaviorAction> processSwipedWithBehavior(
    Tile tile,
    int x,
    int y,
    GameEmoji targetEmoji,
  ) {
    return _behavior.processSwipedWithBehavior(tile, x, y, targetEmoji);
  }

  List<BehaviorAction> processTappedBehavior(Tile tile, int x, int y) {
    return _behavior.processTappedBehavior(tile, x, y);
  }

  bool get hasPendingBlastBehaviors => _behavior.hasPendingBlastBehaviors;

  void processPendingBlasts() => _behavior.processPendingBlasts();

  bool hasTapBehavior(Tile tile, int x, int y) {
    return _behavior.hasTapBehavior(tile, x, y);
  }

  void initializeBehaviors() {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        if (grid[r][c].behavior == null) {
          _behavior.initializeBehavior(grid[r][c]);
        }
      }
    }
  }
}

class _HintScanArgs {
  final List<List<String>> gridVisuals;
  final List<List<bool>> hasBehavior;
  final int rows;
  final int cols;
  final String targetVisual;
  final Set<String> targetIngredients;
  final Set<String> unmatchableVisuals;

  _HintScanArgs({
    required this.gridVisuals,
    required this.hasBehavior,
    required this.rows,
    required this.cols,
    required this.targetVisual,
    required this.targetIngredients,
    required this.unmatchableVisuals,
  });
}

List<int>? _hintScanIsolate(_HintScanArgs args) {
  final rows = args.rows;
  final cols = args.cols;
  final g = List<List<String>>.from(
    args.gridVisuals.map((r) => List<String>.from(r)),
  );
  final unmatchable = args.unmatchableVisuals;

  final List<({List<int> coords, int score})> validMoves = [];

  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      if (c < cols - 1) {
        final score = _scoreHintMove(
          g,
          r,
          c,
          r,
          c + 1,
          rows,
          cols,
          args,
          unmatchable,
        );
        if (score != null) {
          validMoves.add((coords: [r, c, r, c + 1], score: score));
        }
      }
      if (r < rows - 1) {
        final score = _scoreHintMove(
          g,
          r,
          c,
          r + 1,
          c,
          rows,
          cols,
          args,
          unmatchable,
        );
        if (score != null) {
          validMoves.add((coords: [r, c, r + 1, c], score: score));
        }
      }
    }
  }

  if (validMoves.isEmpty) return null;
  validMoves.sort((a, b) => b.score.compareTo(a.score));
  final topScore = validMoves.first.score;
  final best = validMoves.where((m) => m.score == topScore).toList()..shuffle();
  return best.first.coords;
}

int? _scoreHintMove(
  List<List<String>> g,
  int r1,
  int c1,
  int r2,
  int c2,
  int rows,
  int cols,
  _HintScanArgs args,
  Set<String> unmatchable,
) {
  if (args.hasBehavior[r1][c1] || args.hasBehavior[r2][c2]) return 50;

  final tmp = g[r1][c1];
  g[r1][c1] = g[r2][c2];
  g[r2][c2] = tmp;

  final matched = _scanMatchGroups(g, rows, cols, unmatchable);

  g[r2][c2] = g[r1][c1];
  g[r1][c1] = tmp;

  if (matched.isEmpty) return null;

  int score = 100;
  if (matched.any((m) => m.isSpecial)) score += 75;
  if (args.targetIngredients.contains(g[r1][c1]) ||
      args.targetIngredients.contains(g[r2][c2])) {
    score += 50;
  }
  if (matched.any((m) => m.emoji == args.targetVisual)) score += 100;
  score += (r1 > r2 ? r1 : r2);
  return score;
}

class _IsoGroup {
  final String emoji;
  final bool isSpecial;
  const _IsoGroup(this.emoji, {this.isSpecial = false});
}

List<_IsoGroup> _scanMatchGroups(
  List<List<String>> g,
  int rows,
  int cols,
  Set<String> unmatchable,
) {
  final groups = <_IsoGroup>[];
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
        groups.add(_IsoGroup(h.emoji, isSpecial: true));
        foundIntersect = true;
        break;
      }
    }
    if (!foundIntersect) groups.add(_IsoGroup(h.emoji));
  }

  for (final v in vRuns) {
    final alreadyCovered = groups.any((g) => g.isSpecial && g.emoji == v.emoji);
    if (!alreadyCovered) groups.add(_IsoGroup(v.emoji));
  }

  return groups;
}
