import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/reactions/elemental_explosions.dart';
import 'package:grimoji/features/alchemy/reactions/nature_explosions.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/alchemy/recipes/elements.dart';
import 'package:grimoji/features/alchemy/recipes/nature.dart';

class RecipeBook {
  static const List<Recipe> allRecipes = [
    ...elementalRecipes,
    ...natureRecipes,
  ];

  static final List<Reaction> allReactions = [
    NatureReactions(),
    ElementalReactions(),
  ];

  static final Map<GameEmoji, Recipe> _recipeCache = {
    for (var recipe in allRecipes) recipe.ingredient: recipe
  };

  static final Map<GameEmoji, Reaction> _triggerCache = {};

  static Recipe? getRecipeFor(GameEmoji emoji) {
    return _recipeCache[emoji]; 
  }

  static Reaction? getReactionFor(GameEmoji emoji) {
    return _triggerCache[emoji];
  }

  static Map<GameEmoji, GameEmoji> getTransformationsForType(ReactionType type) {
    final reaction = allReactions.firstWhere(
      (r) => r.type == type,
    );
    return reaction.transformations;
  }

  static void initialize() {
    for (final reaction in allReactions) {
      for (final trigger in reaction.triggers) {
        _triggerCache[trigger] = reaction;
      }
    }
  }
}