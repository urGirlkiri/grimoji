import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/game/board/manager.dart';
import 'package:grimoji/features/game/engines/alchemy_engine.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/game/state.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:mockito/mockito.dart';

class MockGameState extends Mock implements GameState {
  @override
  void resolveEmoji(emoji, int count) {}
}

void main() {
  group('AlchemyEngine Tests', () {
    late GridManager gridManager;
    late AlchemyEngine alchemyEngine;
    late MockGameState mockState;
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

      gridManager = GridManager(level);
      gridManager.initialize();

      alchemyEngine = AlchemyEngine(
        gridManager: gridManager,
        getRecipes: RecipeBook.getRecipesFor,
        getReactionFor: RecipeBook.getReactionFor,
        getTransformationsForType: RecipeBook.getTransformationsForType,
        getAoERadiusForType: RecipeBook.getAoERadiusForType,
      );

      mockState = MockGameState();
    });

    test('Should merge N ingredients into Yield dynamically', () {
      final mergeRecipe = RecipeBook.allRecipes.first;

      final matchCoords = <TileCoordinate>{};
      for (int i = 0; i < mergeRecipe.requiredAmount; i++) {
        gridManager.gridTiles[0][i].emoji = mergeRecipe.ingredient;
        matchCoords.add(TileCoordinate(row: 0, col: i));
      }

      final mergePoint = TileCoordinate(row: 0, col: 1);

      alchemyEngine.processMatches(matchCoords, mockState, mergePoint: mergePoint);

       expect(gridManager.gridTiles[0][1].emoji.visual, equals(mergeRecipe.yields.visual));
    });

    test('Should execute a Transmutation Explosion dynamically', () {
      final explosiveRecipe = RecipeBook.allRecipes.firstWhere(
        (r) =>  RecipeBook.getReactionFor(r.yields)?.type == ReactionType.explosive,
        orElse: () => throw Exception('No explosive recipe found'),
      );
      final explosiveEmoji = explosiveRecipe.yields;
      final reaction = RecipeBook.getReactionFor(explosiveEmoji)!;

      final transmutationMap = RecipeBook.getTransformationsForType(reaction.type);
      if (transmutationMap.isEmpty) throw Exception('No transmutations exist for this explosive type');
      
      final sourceEmoji = transmutationMap.keys.first;
      final targetEmoji = transmutationMap[sourceEmoji]!;

      final genericEmoji = RecipeBook.allRecipes.first.ingredient;
      for (int r = 0; r < GridManager.rows; r++) {
        for (int c = 0; c < GridManager.cols; c++) {
          gridManager.gridTiles[r][c].emoji = genericEmoji;
        }
      }

      gridManager.gridTiles[3][2].emoji = explosiveEmoji;
      gridManager.gridTiles[3][3].emoji = sourceEmoji;
      gridManager.triggerInitialFall();

      alchemyEngine.processMatches({TileCoordinate(row: 3, col: 2)}, mockState);
      
      expect(gridManager.gridTiles[3][2].isTriggered, isTrue, reason: 'Explosive should be primed');

      final blastResult = gridManager.executeBlastRadius(TileCoordinate(row: 3, col: 2));

      expect(blastResult.destroyed.contains(TileCoordinate(row: 3, col: 3)), isFalse, reason: 'Transmuted tile should NOT be destroyed');
      expect(blastResult.transformed.contains(TileCoordinate(row: 3, col: 3)), isTrue, reason: 'Tile should be in transformed set');
      expect(gridManager.gridTiles[3][3].emoji.visual, equals(targetEmoji.visual), reason: 'Tile should transform into the target mapped emoji');
    });

    test('Crafting an Explosive should NOT self-ignite dynamically', () {
      final explosiveRecipe = RecipeBook.allRecipes.firstWhere(
        (r) => RecipeBook.getReactionFor(r.yields)?.type == ReactionType.explosive,
      );

      final matchCoords = <TileCoordinate>{};
      for (int i = 0; i < explosiveRecipe.requiredAmount; i++) {
        gridManager.gridTiles[0][i].emoji = explosiveRecipe.ingredient;
        matchCoords.add(TileCoordinate(row: 0, col: i));
      }

      final mergePoint = TileCoordinate(row: 0, col: 1);

      alchemyEngine.processMatches(matchCoords, mockState, mergePoint: mergePoint);

      final craftedTile = gridManager.gridTiles[0][1];
      expect(craftedTile.emoji.visual, equals(explosiveRecipe.yields.visual));
      expect(craftedTile.isTriggered, isFalse, reason: 'Newly crafted explosive MUST NOT self-ignite');
    });

    test('Explosive hitting Explosive should PRIME it', () {
      final explosiveEmoji = RecipeBook.allRecipes.firstWhere(
        (r) => RecipeBook.getReactionFor(r.yields)?.type == ReactionType.explosive,
      ).yields;

      gridManager.triggerInitialFall();
      TileCoordinate center = TileCoordinate(row: 4, col: 2);
      TileCoordinate adjacent = TileCoordinate(row: 4, col: 3);
      
      gridManager.gridTiles[center.row][center.col].emoji = explosiveEmoji;
      gridManager.gridTiles[adjacent.row][adjacent.col].emoji = explosiveEmoji;

      final blastResult = gridManager.executeBlastRadius(center);

      expect(blastResult.destroyed.contains(adjacent), isFalse, reason: 'Caught explosive should NOT be destroyed');
      expect(gridManager.gridTiles[adjacent.row][adjacent.col].isTriggered, isTrue, reason: 'Caught explosive should be primed for chain reaction');
    });

    test('Should destroy tiles normally when NO recipe exists (Basic Match-3)', () {
      final basicEmoji = RecipeBook.allRecipes.first.ingredient;
      final nonRecipeEmoji = level.availableEmojis.firstWhere(
        (emoji) => RecipeBook.getRecipesFor(emoji) == null || RecipeBook.getRecipesFor(emoji)!.isEmpty,
        orElse: () => basicEmoji, 
      );

      gridManager.gridTiles[0][0].emoji = nonRecipeEmoji;
      gridManager.gridTiles[0][1].emoji = nonRecipeEmoji;
      gridManager.gridTiles[0][2].emoji = nonRecipeEmoji;

      final matchCoords = {
        TileCoordinate(row: 0, col: 0),
        TileCoordinate(row: 0, col: 1),
        TileCoordinate(row: 0, col: 2),
      };

      final destroyedTiles = alchemyEngine.processMatches(matchCoords, mockState);

      expect(destroyedTiles.length, equals(3), reason: 'Basic match should return all tiles for destruction');
      expect(gridManager.gridTiles[0][0].isTriggered, isFalse);
      expect(gridManager.gridTiles[0][0].isTransmuting, isFalse);
    });

    test('Should NOT merge when match size is LESS than requiredAmount', () {
      final largeRecipe = RecipeBook.allRecipes.firstWhere(
        (r) => r.requiredAmount > 3,
        orElse: () => throw Exception('No recipes requiring > 3 items found'),
      );

      final matchSize = largeRecipe.requiredAmount - 1;
      final matchCoords = <TileCoordinate>{};
      
      for (int i = 0; i < matchSize; i++) {
        gridManager.gridTiles[0][i].emoji = largeRecipe.ingredient;
        matchCoords.add(TileCoordinate(row: 0, col: i));
      }

      final destroyedTiles = alchemyEngine.processMatches(matchCoords, mockState);

      expect(destroyedTiles.length, equals(matchSize), reason: 'Insufficient recipe match should default to destruction');
      expect(gridManager.gridTiles[0][0].emoji.visual, equals(largeRecipe.ingredient.visual), reason: 'Tile should NOT have transformed');
    });

    test('Should execute explosion strictly within its AoE radius', () {
      final explosiveEmoji = RecipeBook.allRecipes.firstWhere(
        (r) =>  RecipeBook.getReactionFor(r.yields)?.type == ReactionType.explosive,
      ).yields;
      
      final reaction = RecipeBook.getReactionFor(explosiveEmoji)!;
      final radius = RecipeBook.getAoERadiusForType(reaction.type);

      final genericEmoji = RecipeBook.allRecipes.first.ingredient;
      for (int r = 0; r < GridManager.rows; r++) {
        for (int c = 0; c < GridManager.cols; c++) {
          gridManager.gridTiles[r][c].emoji = genericEmoji;
        }
      }

      final centerRow = 4;
      final centerCol = 2;
      gridManager.gridTiles[centerRow][centerCol].emoji = explosiveEmoji;
      
      final blastResult = gridManager.executeBlastRadius(TileCoordinate(row: centerRow, col: centerCol));

      final safeRow = centerRow + radius + 1;
      final safeCol = centerCol;
      
      expect(blastResult.destroyed.contains(TileCoordinate(row: safeRow, col: safeCol)), isFalse, reason: 'Tile outside radius should not be destroyed');
      expect(blastResult.transformed.contains(TileCoordinate(row: safeRow, col: safeCol)), isFalse, reason: 'Tile outside radius should not be transformed');
    });
  });
}