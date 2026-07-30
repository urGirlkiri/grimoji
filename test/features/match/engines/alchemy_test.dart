import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/engines/alchemy.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/detectors/match.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import '../../../helpers/test_grid.dart';

void main() {
  group('AlchemyEngine Tests', () {
    late BoardManager boardManager;
    late AlchemyEngine alchemyEngine;
    late TestGrid grid;

    setUp(() {
      RecipeBook.initialize();

      final allKnownEmojis = RecipeBook.allRecipes
          .map((r) => r.ingredient)
          .toSet()
          .toList();

      final level = GameLevel(
        number: 1,
        timeLimit: 60,
        targetEmoji: allKnownEmojis.isNotEmpty
            ? allKnownEmojis.first
            : throw Exception('No emojis found'),
        targetAmount: 1,
        availableEmojis: allKnownEmojis,
      );

      boardManager = BoardManager(level);
      boardManager.initialize();
      grid = TestGrid(boardManager);

      alchemyEngine = AlchemyEngine(
        boardManager: boardManager,
        playSfx: (type) {},
        getRecipes: RecipeBook.getRecipesFor,
        getReactionFor: RecipeBook.getReactionFor,
        getTransformationsForType: RecipeBook.getTransformationsForType,
        getAoERadiusForType: RecipeBook.getAoERadiusForType,
      );
    });

    test('Should merge N ingredients into Yield dynamically', () {
      final mergeRecipe = RecipeBook.allRecipes.first;

      for (int i = 0; i < mergeRecipe.requiredAmount; i++) {
        grid.place(0, i, mergeRecipe.ingredient);
      }

      final matchGroups = MatchDetector.findMatchedGroups(
        boardManager.gridTiles,
      );
      final targetCoord = TileCoordinate(row: 0, col: 1);

      alchemyEngine.processCascadeStep(
        matchedGroups: matchGroups,
        targetCoordinate: targetCoord,
        isFirstMatch: true,
      );

      expect(
        boardManager.gridTiles[0][1].emoji.visual,
        equals(mergeRecipe.yields.visual),
      );
    });

    test('Should execute a Transmutation Explosion dynamically', () {
      final explosiveRecipe = RecipeBook.allRecipes.firstWhere(
        (r) =>
            RecipeBook.getReactionFor(r.yields)?.type == ReactionType.explosive,
        orElse: () => throw Exception('No explosive recipe found'),
      );
      final explosiveEmoji = explosiveRecipe.yields;
      final reaction = RecipeBook.getReactionFor(explosiveEmoji)!;

      final transmutationMap = RecipeBook.getTransformationsForType(
        reaction.type,
      );
      if (transmutationMap.isEmpty) {
        throw Exception('No transmutations exist for this explosive type');
      }

      final sourceEmoji = transmutationMap.keys.first;
      final targetEmoji = transmutationMap[sourceEmoji]!;

      final genericEmoji = RecipeBook.allRecipes.first.ingredient;
      grid.fill(genericEmoji);

      grid.place(3, 1, explosiveEmoji);
      grid.place(3, 2, explosiveEmoji);
      grid.place(3, 3, explosiveEmoji);
      grid.place(3, 4, sourceEmoji);
      boardManager.triggerInitialFall();

      final matchGroups = MatchDetector.findMatchedGroups(
        boardManager.gridTiles,
      );
      alchemyEngine.processCascadeStep(
        matchedGroups: matchGroups,
        targetCoordinate: TileCoordinate(row: 3, col: 2),
        isFirstMatch: true,
      );

      expect(
        boardManager.gridTiles[3][2].isTriggered,
        isTrue,
        reason: 'Explosive should be primed',
      );

      final detonationResult = alchemyEngine.processDetonationStep();

      expect(
        detonationResult.transformed.contains(TileCoordinate(row: 3, col: 4)),
        isTrue,
        reason: 'Tile should be in transformed set',
      );
      expect(
        boardManager.gridTiles[3][4].emoji.visual,
        equals(targetEmoji.visual),
        reason: 'Tile should transform into the target mapped emoji',
      );
    });

    test('Crafting an Explosive should NOT self-ignite dynamically', () {
      final explosiveRecipe = RecipeBook.allRecipes.firstWhere(
        (r) =>
            RecipeBook.getReactionFor(r.yields)?.type == ReactionType.explosive,
      );

      for (int i = 0; i < explosiveRecipe.requiredAmount; i++) {
        grid.place(0, i, explosiveRecipe.ingredient);
      }

      final matchGroups = MatchDetector.findMatchedGroups(
        boardManager.gridTiles,
      );
      alchemyEngine.processCascadeStep(
        matchedGroups: matchGroups,
        targetCoordinate: TileCoordinate(row: 0, col: 1),
        isFirstMatch: true,
      );

      final craftedTile = boardManager.gridTiles[0][1];
      expect(craftedTile.emoji.visual, equals(explosiveRecipe.yields.visual));
      expect(
        craftedTile.isTriggered,
        isFalse,
        reason: 'Newly crafted explosive MUST NOT self-ignite',
      );
    });

    test(
      'Explosive hitting Explosive should PRIME adjacent explosives when no merge',
      () {
        final explosiveEmoji = RecipeBook.allRecipes
            .firstWhere(
              (r) =>
                  RecipeBook.getReactionFor(r.yields)?.type ==
                  ReactionType.explosive,
            )
            .yields;

        boardManager.triggerInitialFall();
        grid.place(4, 1, explosiveEmoji);
        grid.place(4, 2, explosiveEmoji);
        grid.place(4, 3, explosiveEmoji);
        grid.place(4, 0, Emojis.fire);
        grid.place(3, 1, explosiveEmoji);

        final matchGroups = MatchDetector.findMatchedGroups(
          boardManager.gridTiles,
        );
        alchemyEngine.processCascadeStep(
          matchedGroups: matchGroups,
          targetCoordinate: TileCoordinate(row: 4, col: 2),
          isFirstMatch: true,
        );

        final detonationResult = alchemyEngine.processDetonationStep();

        expect(
          boardManager.gridTiles[3][1].isTriggered ||
              detonationResult.destroyed.contains(
                TileCoordinate(row: 3, col: 1),
              ),
          isTrue,
          reason: 'Adjacent explosive should either be primed or destroyed',
        );
      },
    );

    test(
      'Should destroy tiles normally when NO recipe exists (Basic Match-3)',
      () {
        final nonRecipeEmoji = Emojis.avocado;

        grid.place(0, 0, nonRecipeEmoji);
        grid.place(0, 1, nonRecipeEmoji);
        grid.place(0, 2, nonRecipeEmoji);

        final matchGroups = MatchDetector.findMatchedGroups(
          boardManager.gridTiles,
        );
        final result = alchemyEngine.processCascadeStep(
          matchedGroups: matchGroups,
          targetCoordinate: TileCoordinate(row: 0, col: 0),
          isFirstMatch: true,
        );

        expect(
          result.tilesToDestroy.length,
          equals(3),
          reason: 'Basic match should return all tiles for destruction',
        );
        expect(boardManager.gridTiles[0][0].isTriggered, isFalse);
        expect(boardManager.gridTiles[0][0].isTransmuting, isFalse);
      },
    );

    test('Should NOT merge when match size is LESS than requiredAmount', () {
      final candidates = RecipeBook.allRecipes
          .where(
            (r) =>
                r.requiredAmount > 3 &&
                !(RecipeBook.getRecipesFor(
                  r.ingredient,
                )!.any((other) => other.requiredAmount <= 3)) &&
                RecipeBook.getReactionFor(r.ingredient) == null,
          )
          .toList();

      if (candidates.isEmpty) {
        throw Exception(
          'No recipes requiring > 3 items found with no smaller alternatives and no reaction',
        );
      }

      candidates.sort(
        (a, b) => a.ingredient.visual.compareTo(b.ingredient.visual),
      );
      final largeRecipe = candidates.first;

      final matchSize = largeRecipe.requiredAmount - 1;

      for (int i = 0; i < matchSize; i++) {
        grid.place(0, i, largeRecipe.ingredient);
      }

      final matchGroups = MatchDetector.findMatchedGroups(
        boardManager.gridTiles,
      );
      final result = alchemyEngine.processCascadeStep(
        matchedGroups: matchGroups,
        targetCoordinate: TileCoordinate(row: 0, col: 0),
        isFirstMatch: true,
      );

      expect(
        result.tilesToDestroy.length,
        equals(matchSize),
        reason: 'Insufficient recipe match should default to destruction',
      );
      expect(
        boardManager.gridTiles[0][0].emoji.visual,
        equals(largeRecipe.ingredient.visual),
        reason: 'Tile should NOT have transformed',
      );
    });

    test('Should execute explosion strictly within its AoE radius', () {
      final explosiveEmoji = RecipeBook.allRecipes
          .firstWhere(
            (r) =>
                RecipeBook.getReactionFor(r.yields)?.type ==
                ReactionType.explosive,
          )
          .yields;

      final reaction = RecipeBook.getReactionFor(explosiveEmoji)!;
      final radius = RecipeBook.getAoERadiusForType(reaction.type);

      final genericEmoji = RecipeBook.allRecipes.first.ingredient;
      grid.fill(genericEmoji);

      const centerRow = 4;
      const centerCol = 2;
      grid.place(centerRow, centerCol, explosiveEmoji);

      final matchGroups = MatchDetector.findMatchedGroups(
        boardManager.gridTiles,
      );
      alchemyEngine.processCascadeStep(
        matchedGroups: matchGroups,
        targetCoordinate: TileCoordinate(row: centerRow, col: centerCol),
        isFirstMatch: true,
      );

      final detonationResult = alchemyEngine.processDetonationStep();

      final safeRow = centerRow + radius + 1;
      const safeCol = centerCol;

      expect(
        detonationResult.destroyed.contains(
          TileCoordinate(row: safeRow, col: safeCol),
        ),
        isFalse,
        reason: 'Tile outside radius should not be destroyed',
      );
      expect(
        detonationResult.transformed.contains(
          TileCoordinate(row: safeRow, col: safeCol),
        ),
        isFalse,
        reason: 'Tile outside radius should not be transformed',
      );
    });
  });
}
