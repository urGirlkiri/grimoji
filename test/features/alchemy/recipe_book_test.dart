import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
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

        expect(explosiveTransformations.containsKey(Emojis.bone), isTrue);
        expect(explosiveTransformations[Emojis.bone], equals(Emojis.ghost));
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
  });
}
