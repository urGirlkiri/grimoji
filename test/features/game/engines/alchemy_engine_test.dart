import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/game/board/utils/manager.dart';
import 'package:grimoji/features/game/engines/alchemy_engine.dart';
import 'package:grimoji/features/game/board/models/coordinate.dart';
import 'package:grimoji/features/game/utils/match_detector.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

void main() {
  group('AlchemyEngine Tests', () {
    late BoardManager boardManager;
    late AlchemyEngine alchemyEngine;
    late GameLevel level;

    setUp(() {
      RecipeBook.initialize();

      final allKnownEmojis = RecipeBook.allRecipes.map((r) => r.ingredient).toSet().toList();

      level = GameLevel(
        number: 1,
        timeLimit: 60,
        targetEmoji: allKnownEmojis.isNotEmpty ? allKnownEmojis.first : throw Exception('No emojis found'),
        targetAmount: 1,
        availableEmojis: allKnownEmojis,
        goal: 'Test goal',
        description: 'Test description',
      );

      boardManager = BoardManager(level);
      boardManager.initialize();

      alchemyEngine = AlchemyEngine(
        boardManager: boardManager,
        getRecipes: RecipeBook.getRecipesFor,
        getReactionFor: RecipeBook.getReactionFor,
        getTransformationsForType: RecipeBook.getTransformationsForType,
        getAoERadiusForType: RecipeBook.getAoERadiusForType,
      );
    });

    test('Should merge N ingredients into Yield dynamically', () {
      final mergeRecipe = RecipeBook.allRecipes.first;

      for (int i = 0; i < mergeRecipe.requiredAmount; i++) {
        boardManager.gridTiles[0][i].emoji = mergeRecipe.ingredient;
      }

      final matchGroups = MatchDetector.findMatchedGroups(boardManager.gridTiles);
      final targetCoord = TileCoordinate(row: 0, col: 1);

      alchemyEngine.processCascadeStep(
        matchedGroups: matchGroups,
        targetCoordinate: targetCoord,
        isFirstMatch: true,
      );

      expect(boardManager.gridTiles[0][1].emoji.visual, equals(mergeRecipe.yields.visual));
    });

    test('Should execute a Transmutation Explosion dynamically', () {
      final explosiveRecipe = RecipeBook.allRecipes.firstWhere(
        (r) => RecipeBook.getReactionFor(r.yields)?.type == ReactionType.explosive,
        orElse: () => throw Exception('No explosive recipe found'),
      );
      final explosiveEmoji = explosiveRecipe.yields;
      final reaction = RecipeBook.getReactionFor(explosiveEmoji)!;

      final transmutationMap = RecipeBook.getTransformationsForType(reaction.type);
      if (transmutationMap.isEmpty) throw Exception('No transmutations exist for this explosive type');
      
      final sourceEmoji = transmutationMap.keys.first;
      final targetEmoji = transmutationMap[sourceEmoji]!;

      final genericEmoji = RecipeBook.allRecipes.first.ingredient;
      for (int r = 0; r < BoardManager.rows; r++) {
        for (int c = 0; c < BoardManager.cols; c++) {
          boardManager.gridTiles[r][c].emoji = genericEmoji;
        }
      }

      boardManager.gridTiles[3][1].emoji = explosiveEmoji;
      boardManager.gridTiles[3][2].emoji = explosiveEmoji;
      boardManager.gridTiles[3][3].emoji = explosiveEmoji;
      boardManager.gridTiles[3][4].emoji = sourceEmoji;
      boardManager.triggerInitialFall();

      final matchGroups = MatchDetector.findMatchedGroups(boardManager.gridTiles);
      alchemyEngine.processCascadeStep(
        matchedGroups: matchGroups,
        targetCoordinate: TileCoordinate(row: 3, col: 2),
        isFirstMatch: true,
      );
      
      expect(boardManager.gridTiles[3][2].isTriggered, isTrue, reason: 'Explosive should be primed');

      final detonationResult = alchemyEngine.processDetonationStep();

      expect(detonationResult.transformed.contains(TileCoordinate(row: 3, col: 4)), isTrue, reason: 'Tile should be in transformed set');
      expect(boardManager.gridTiles[3][4].emoji.visual, equals(targetEmoji.visual), reason: 'Tile should transform into the target mapped emoji');
    });

    test('Crafting an Explosive should NOT self-ignite dynamically', () {
      final explosiveRecipe = RecipeBook.allRecipes.firstWhere(
        (r) => RecipeBook.getReactionFor(r.yields)?.type == ReactionType.explosive,
      );

      for (int i = 0; i < explosiveRecipe.requiredAmount; i++) {
        boardManager.gridTiles[0][i].emoji = explosiveRecipe.ingredient;
      }

      final matchGroups = MatchDetector.findMatchedGroups(boardManager.gridTiles);
      alchemyEngine.processCascadeStep(
        matchedGroups: matchGroups,
        targetCoordinate: TileCoordinate(row: 0, col: 1),
        isFirstMatch: true,
      );

      final craftedTile = boardManager.gridTiles[0][1];
      expect(craftedTile.emoji.visual, equals(explosiveRecipe.yields.visual));
      expect(craftedTile.isTriggered, isFalse, reason: 'Newly crafted explosive MUST NOT self-ignite');
    });

    test('Explosive hitting Explosive should PRIME adjacent explosives when no merge', () {
      final explosiveEmoji = RecipeBook.allRecipes.firstWhere(
        (r) => RecipeBook.getReactionFor(r.yields)?.type == ReactionType.explosive,
      ).yields;

      boardManager.triggerInitialFall();
      boardManager.gridTiles[4][1].emoji = explosiveEmoji;
      boardManager.gridTiles[4][2].emoji = explosiveEmoji;
      boardManager.gridTiles[4][3].emoji = explosiveEmoji;
      boardManager.gridTiles[4][0].emoji = Emojis.fire;
      boardManager.gridTiles[3][1].emoji = explosiveEmoji;

      final matchGroups = MatchDetector.findMatchedGroups(boardManager.gridTiles);
      alchemyEngine.processCascadeStep(
        matchedGroups: matchGroups,
        targetCoordinate: TileCoordinate(row: 4, col: 2),
        isFirstMatch: true,
      );

      final detonationResult = alchemyEngine.processDetonationStep();

      expect(boardManager.gridTiles[3][1].isTriggered || detonationResult.destroyed.contains(TileCoordinate(row: 3, col: 1)), isTrue, 
        reason: 'Adjacent explosive should either be primed or destroyed');
    });

    test('Should destroy tiles normally when NO recipe exists (Basic Match-3)', () {
      final nonRecipeEmoji = Emojis.avocado; 

      boardManager.gridTiles[0][0].emoji = nonRecipeEmoji;
      boardManager.gridTiles[0][1].emoji = nonRecipeEmoji;
      boardManager.gridTiles[0][2].emoji = nonRecipeEmoji;

      final matchGroups = MatchDetector.findMatchedGroups(boardManager.gridTiles);
      final result = alchemyEngine.processCascadeStep(
        matchedGroups: matchGroups,
        targetCoordinate: TileCoordinate(row: 0, col: 0),
        isFirstMatch: true,
      );

      expect(result.tilesToDestroy.length, equals(3), reason: 'Basic match should return all tiles for destruction');
      expect(boardManager.gridTiles[0][0].isTriggered, isFalse);
      expect(boardManager.gridTiles[0][0].isTransmuting, isFalse);
    });

    test('Should NOT merge when match size is LESS than requiredAmount', () {
      final largeRecipe = RecipeBook.allRecipes.firstWhere(
        (r) => r.requiredAmount > 3 && 
               !(RecipeBook.getRecipesFor(r.ingredient)!.any((other) => other.requiredAmount <= 3)) &&
               RecipeBook.getReactionFor(r.ingredient) == null,
        orElse: () => throw Exception('No recipes requiring > 3 items found with no smaller alternatives and no reaction'),
      );

      final matchSize = largeRecipe.requiredAmount - 1;
      
      for (int i = 0; i < matchSize; i++) {
        boardManager.gridTiles[0][i].emoji = largeRecipe.ingredient;
      }

      final matchGroups = MatchDetector.findMatchedGroups(boardManager.gridTiles);
      final result = alchemyEngine.processCascadeStep(
        matchedGroups: matchGroups,
        targetCoordinate: TileCoordinate(row: 0, col: 0),
        isFirstMatch: true,
      );

      expect(result.tilesToDestroy.length, equals(matchSize), reason: 'Insufficient recipe match should default to destruction');
      expect(boardManager.gridTiles[0][0].emoji.visual, equals(largeRecipe.ingredient.visual), reason: 'Tile should NOT have transformed');
    });

    test('Should execute explosion strictly within its AoE radius', () {
      final explosiveEmoji = RecipeBook.allRecipes.firstWhere(
        (r) => RecipeBook.getReactionFor(r.yields)?.type == ReactionType.explosive,
      ).yields;
      
      final reaction = RecipeBook.getReactionFor(explosiveEmoji)!;
      final radius = RecipeBook.getAoERadiusForType(reaction.type);

      final genericEmoji = RecipeBook.allRecipes.first.ingredient;
      for (int r = 0; r < BoardManager.rows; r++) {
        for (int c = 0; c < BoardManager.cols; c++) {
          boardManager.gridTiles[r][c].emoji = genericEmoji;
        }
      }

      final centerRow = 4;
      final centerCol = 2;
      boardManager.gridTiles[centerRow][centerCol].emoji = explosiveEmoji;
      
      final matchGroups = MatchDetector.findMatchedGroups(boardManager.gridTiles);
      alchemyEngine.processCascadeStep(
        matchedGroups: matchGroups,
        targetCoordinate: TileCoordinate(row: centerRow, col: centerCol),
        isFirstMatch: true,
      );

      final detonationResult = alchemyEngine.processDetonationStep();

      final safeRow = centerRow + radius + 1;
      final safeCol = centerCol;
      
      expect(detonationResult.destroyed.contains(TileCoordinate(row: safeRow, col: safeCol)), isFalse, reason: 'Tile outside radius should not be destroyed');
      expect(detonationResult.transformed.contains(TileCoordinate(row: safeRow, col: safeCol)), isFalse, reason: 'Tile outside radius should not be transformed');
    });
  });
}