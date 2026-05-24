import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/behavior_register.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/game/board/models/coordinate.dart';
import 'package:grimoji/features/game/board/models/tile.dart';
import 'package:grimoji/features/game/board/utils/manager.dart';
import 'package:grimoji/features/game/model/cascade_step_result.dart';
import 'package:grimoji/features/game/model/detonation_step_result.dart';
import 'package:grimoji/features/game/utils/swipe_detector.dart';
import 'package:grimoji/features/game/utils/match_detector.dart';
import 'alchemy_engine.dart';
import 'behavior_engine.dart';

class GameEngine {
  final GameLevel level;
  final BoardManager boardManager;

  late final AlchemyEngine _alchemy;
  late final BehaviorEngine _behavior;

  GameEngine({required this.level, required this.boardManager}) {
    _behavior = BehaviorEngine(
      boardManager: boardManager,
      getBehavior: BehaviorRegister.getBehaviorFor,
    );

    _alchemy = AlchemyEngine(
      boardManager: boardManager,
      getRecipes: RecipeBook.getRecipesFor,
      getReactionFor: RecipeBook.getReactionFor,
      getTransformationsForType: RecipeBook.getTransformationsForType,
      getAoERadiusForType: RecipeBook.getAoERadiusForType,
      initializeBehavior: _behavior.initializeBehavior,
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
          }
        }
      }
    }
  }

  void shuffleGrid() {
    bool validBoard = false;
    while (!validBoard) {
      boardManager.shuffleGrid();

      validBoard = hasPossibleMoves();
      if (MatchDetector.findMatchedGroups(grid).isNotEmpty) {
        validBoard = false;
      }
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
            quickCheckOnly: true,
          );
          if (d.type != SwipeResult.invalid) return true;
        }
      }
    }
    return false;
  }

  List<TileCoordinate>? getHintMove() {
    List<({List<TileCoordinate> coords, int score})> validMoves = [];
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        if (c < BoardManager.cols - 1) {
          final t1 = TileCoordinate(row: r, col: c);
          final t2 = TileCoordinate(row: r, col: c + 1);
          final d = SwipeDetector.evaluate(
            grid: grid,
            dCoord: t1,
            tCoord: t2,
            getSwipeBehaviors: _behavior.processSwipedWithBehavior,
            quickCheckOnly: true,
          );
          if (d.type != SwipeResult.invalid) {
            validMoves.add((coords: [t1, t2], score: _scoreMove(t1, t2, d)));
          }
        }
        if (r < BoardManager.rows - 1) {
          final t1 = TileCoordinate(row: r, col: c);
          final t2 = TileCoordinate(row: r + 1, col: c);
          final d = SwipeDetector.evaluate(
            grid: grid,
            dCoord: t1,
            tCoord: t2,
            getSwipeBehaviors: _behavior.processSwipedWithBehavior,
            quickCheckOnly: true,
          );
          if (d.type != SwipeResult.invalid) {
            validMoves.add((coords: [t1, t2], score: _scoreMove(t1, t2, d)));
          }
        }
      }
    }

    if (validMoves.isEmpty) return null;
    validMoves.sort((a, b) => b.score.compareTo(a.score));
    final topScore = validMoves.first.score;
    final bestMoves = validMoves.where((m) => m.score == topScore).toList();
    bestMoves.shuffle();
    return bestMoves.first.coords;
  }

  int _scoreMove(TileCoordinate t1, TileCoordinate t2, SwipeDecision decision) {
    int score = (decision.type == SwipeResult.match) ? 100 : 0;
    if (_isTargetIngredient(grid[t1.row][t1.col].emoji) ||
        _isTargetIngredient(grid[t2.row][t2.col].emoji)) {
      score += 50;
    }
    score += (t1.row > t2.row ? t1.row : t2.row);
    return score;
  }

  bool _isTargetIngredient(GameEmoji emoji) {
    return RecipeBook.allRecipes.any(
      (r) => r.yields == level.targetEmoji && r.ingredient == emoji,
    );
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

}
