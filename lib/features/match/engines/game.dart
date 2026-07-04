import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/behavior_register.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
import 'package:grimoji/features/match/utils/manager.dart';
import 'package:grimoji/features/match/model/cascade_step_result.dart';
import 'package:grimoji/features/match/model/detonation_step_result.dart';
import 'package:grimoji/features/match/detectors/swipe_detector.dart';
import 'package:grimoji/features/match/detectors/match_detector.dart';
import 'package:grimoji/features/match/detectors/hint_detector.dart';
import 'alchemy.dart';
import 'behavior.dart';

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

  Future<List<TileCoordinate>?> getHintMove() =>
      HintDetector.findBestMove(grid: grid, targetEmoji: level.targetEmoji);

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
