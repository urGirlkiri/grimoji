import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';

void main() {
  group('RecipeBook Tests', () {
    test('allRecipes should not contain duplicate ids', () {
      final recipeIds = RecipeBook.allRecipes.map((r) => r.id).toList();
      final duplicates = recipeIds
          .where((id) => recipeIds.indexOf(id) != recipeIds.lastIndexOf(id))
          .toList();

      expect(
        recipeIds.length,
        equals(recipeIds.toSet().length),
        reason:
            'There are duplicate recipes with the same ingredient and required amount: ${duplicates.toSet().join(', ')}',
      );
    });

    test('getRecipeFor should successfully return mapped recipes', () {
      final fireRecipe = RecipeBook.getRecipeFor(Emojis.fire);
      expect(fireRecipe, isNotNull);
      expect(fireRecipe!.yields, equals(Emojis.bomb));
    });

    test('getRecipeFor should return null for normal emojis', () {
      final noEntryRecipe = RecipeBook.getRecipeFor(Emojis.noEntry);
      expect(
        noEntryRecipe,
        isNull,
        reason:
            'NoEntry doesn\'t have a special recipe, so it should return null to let the engine handle them normally',
      );
    });

    test(
      'getTransformationsForType should return the correct reaction maps',
      () {
        final explosiveTransformations = RecipeBook.getTransformationsForType(
          ReactionType.explosive,
        );

        expect(explosiveTransformations, isNotNull);
        expect(explosiveTransformations, isA<Map<GameEmoji, GameEmoji>>());

        expect(explosiveTransformations.containsKey(Emojis.skull), isTrue);
        expect(explosiveTransformations[Emojis.skull], equals(Emojis.ghost));
      },
    );

    test(
      'getTransformationsForType should return freezing transformations when registered',
      () {
        final freezingTransformations = RecipeBook.getTransformationsForType(
          ReactionType.freezing,
        );

        expect(freezingTransformations, isNotNull);
        expect(freezingTransformations, isA<Map<GameEmoji, GameEmoji>>());

        expect(freezingTransformations.containsKey(Emojis.droplet), isTrue);
        expect(freezingTransformations[Emojis.droplet], equals(Emojis.melting));
      },
    );

    test('All recipes must have strictly valid data', () {
      for (final recipe in RecipeBook.allRecipes) {
        expect(
          recipe.yields,
          isNotNull,
          reason: '${recipe.ingredient.visual} is a recipe but yields nothing',
        );
      }
    });

    test('Recipes MUST NOT yield their own ingredient', () {
      for (final recipe in RecipeBook.allRecipes) {
        expect(
          recipe.yields,
          isNot(equals(recipe.ingredient)),
          reason:
              'CRITICAL ERROR: ${recipe.ingredient.visual} yields itself! This will cause an infinite match loop.',
        );
      }
    });

    test('Reactions MUST NOT transform an emoji into itself ', () {
      for (final reaction in RecipeBook.allReactions) {
        reaction.transformations.forEach((inputEmoji, outputEmoji) {
          expect(
            inputEmoji,
            isNot(equals(outputEmoji)),
            reason:
                '${reaction.type.name} reaction turns ${inputEmoji.visual} into itself. This is redundant data!',
          );
        });
      }
    });

    test(
      'All recipes MUST require at least 3 ingredients to prevent accidental auto-merges',
      () {
        for (final recipe in RecipeBook.allRecipes) {
          expect(
            recipe.requiredAmount,
            greaterThanOrEqualTo(3),
            reason:
                'Recipe for ${recipe.yields.visual} requires only ${recipe.requiredAmount} ${recipe.ingredient.visual}. '
                'Minimum requirement is 3 ingredients.',
          );
        }
      },
    );

    test('All recipes MUST NOT have more than 4 ingredients', () {
      for (final recipe in RecipeBook.allRecipes) {
        expect(
          recipe.requiredAmount,
          lessThanOrEqualTo(4),
          reason:
              'Recipe for ${recipe.yields.visual} requires ${recipe.requiredAmount} ${recipe.ingredient.visual}. '
              'Maximum is 4 ingredients.',
        );
      }
    });
    group('Tier System Tests', () {
      test(
        'Base emojis (items never yielded by any recipe) MUST be Tier 1',
        () {
          final yieldedEmojis = RecipeBook.allRecipes
              .map((r) => r.yields)
              .toSet();
          final baseEmojis = RecipeBook.allRecipes
              .map((r) => r.ingredient)
              .where((emoji) => !yieldedEmojis.contains(emoji))
              .toSet();

          expect(
            baseEmojis,
            isNotEmpty,
            reason: 'Game must have at least one base emoji',
          );

          for (final baseEmoji in baseEmojis) {
            expect(
              RecipeBook.getTier(baseEmoji),
              equals(1),
              reason:
                  '${baseEmoji.visual} cannot be crafted, so it must be Tier 1',
            );
          }
        },
      );

      test('Crafted items MUST be a higher tier than their ingredients', () {
        final craftedEmojis = RecipeBook.allRecipes
            .map((r) => r.yields)
            .toSet();

        for (final recipe in RecipeBook.allRecipes) {
          if (craftedEmojis.contains(recipe.yields)) continue;

          final ingredientTier = RecipeBook.getTier(recipe.ingredient);
          final yieldsTier = RecipeBook.getTier(recipe.yields);

          expect(
            yieldsTier,
            greaterThan(ingredientTier),
            reason:
                '${recipe.yields.visual} (Tier $yieldsTier) must be a higher tier '
                'than its ingredient ${recipe.ingredient.visual} (Tier $ingredientTier)',
          );
        }
      });

      test('isLegendary MUST exactly match Tier 5+ logic for all items', () {
        final allCraftedEmojis = RecipeBook.allRecipes
            .map((r) => r.yields)
            .toSet();

        for (final emoji in allCraftedEmojis) {
          final tier = RecipeBook.getTier(emoji);
          final legendary = RecipeBook.isLegendary(emoji);

          expect(
            legendary,
            equals(tier >= 5),
            reason:
                '${emoji.visual} is Tier $tier. isLegendary should be ${tier >= 5}',
          );
        }
      });

      test('Tier calculation should be memoized and consistent', () {
        final dynamicTestEmoji = RecipeBook.allRecipes.first.yields;

        final tier1 = RecipeBook.getTier(dynamicTestEmoji);
        final tier2 = RecipeBook.getTier(dynamicTestEmoji);

        expect(
          tier1,
          equals(tier2),
          reason:
              'Sequential tier checks should return identical results from cache',
        );
      });
    });

    group('Special Recipes Tests', () {
      test('specialRecipes should not be empty', () {
        RecipeBook.initialize();
        expect(
          RecipeBook.specialRecipes,
          isNotEmpty,
          reason: 'Game must have at least one special recipe',
        );
      });

      test('specialRecipes should contain ghost, bomb, and hole recipes', () {
        RecipeBook.initialize();
        final specialYields = RecipeBook.specialRecipes
            .map((r) => r.yields)
            .toSet();

        expect(
          specialYields.contains(Emojis.ghost),
          isTrue,
          reason: 'specialRecipes should contain ghost',
        );
        expect(
          specialYields.contains(Emojis.bomb),
          isTrue,
          reason: 'specialRecipes should contain bomb',
        );
        expect(
          specialYields.contains(Emojis.hole),
          isTrue,
          reason: 'specialRecipes should contain hole',
        );
      });

      test('specialRecipes should contain some powerup emojis', () {
        RecipeBook.initialize();
        final specialYields = RecipeBook.specialRecipes
            .map((r) => r.yields)
            .toSet();

        var powerupInSpecialCount = 0;
        for (final powerup in Powerup.all) {
          final emoji = Powerup.emojiForId(powerup.id);
          if (emoji != null && specialYields.contains(emoji)) {
            powerupInSpecialCount++;
          }
        }

        expect(
          powerupInSpecialCount,
          greaterThan(0),
          reason: 'At least some powerup emojis should be in specialRecipes',
        );
      });
    });
  });
}
