import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/reactions/elemental_explosions.dart';
import 'package:grimoji/features/alchemy/reactions/nature_explosions.dart';
import 'package:grimoji/features/alchemy/reactions/chapter1_reactions.dart';
import 'package:grimoji/features/alchemy/reactions/chapter2_reactions.dart';
import 'package:grimoji/features/alchemy/reactions/chapter3_reactions.dart';
import 'package:grimoji/features/alchemy/reactions/chapter4_reactions.dart';
import 'package:grimoji/features/alchemy/reactions/chapter5_reactions.dart';
import 'package:grimoji/features/alchemy/recipes/chapter1.dart';
import 'package:grimoji/features/alchemy/recipes/chapter2.dart';
import 'package:grimoji/features/alchemy/recipes/chapter3.dart';
import 'package:grimoji/features/alchemy/recipes/chapter4.dart';
import 'package:grimoji/features/alchemy/recipes/chapter5.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

class RecipeBook {
  static const List<Recipe> allRecipes = [
    ...chapter1Recipes,
    ...chapter2Recipes,
    ...chapter3Recipes,
    ...chapter4Recipes,
    ...chapter5Recipes,
  ];

  static final List<Reaction> allReactions = [
    ...Chapter1Reactions.all,
    ...Chapter2Reactions.all,
    ...Chapter3Reactions.all,
    ...Chapter4Reactions.all,
    ...Chapter5Reactions.all,
    ...NatureReactions.all,
    ...ElementalReactions.all,
  ];

  static final Map<GameEmoji, List<Recipe>> _recipeCache = {};
  static final Map<GameEmoji, Reaction> _triggerCache = {};
  static bool _isInitialized = false;

  static void _ensureInitialized() {
    if (_isInitialized) return;
    _isInitialized = true;
    
    for (var recipe in allRecipes) {
      _recipeCache.putIfAbsent(recipe.ingredient, () => []).add(recipe);
    }
    
    for (var list in _recipeCache.values) {
      list.sort((a, b) => b.requiredAmount.compareTo(a.requiredAmount));
    }

    for (final reaction in allReactions) {
      for (final trigger in reaction.triggers) {
        _triggerCache[trigger] = reaction;
      }
    }
  }

  static List<Recipe>? getRecipesFor(GameEmoji emoji) {
    _ensureInitialized();
    return _recipeCache[emoji]; 
  }

  static Reaction? getReactionFor(GameEmoji emoji) {
    _ensureInitialized();
    return _triggerCache[emoji];
  }

  static Map<GameEmoji, GameEmoji> getTransformationsForType(ReactionType type) {
    _ensureInitialized();
    final reaction = allReactions.firstWhere(
      (r) => r.type == type,
      orElse: () => Reaction(
        type: type,
        triggers: [],
        transformations: {},
        aoeRadius: 1,
      ),
    );
    return reaction.transformations;
  }

  static int getAoERadiusForType(ReactionType type) {
    _ensureInitialized();
    final reaction = allReactions.firstWhere(
      (r) => r.type == type,
      orElse: () => Reaction(
        type: type,
        triggers: [],
        transformations: {},
        aoeRadius: 1,
      ),
    );
    return reaction.aoeRadius;
  }

  static void initialize() {
    _ensureInitialized();
  }

  static Recipe? getRecipeFor(GameEmoji emoji) {
    _ensureInitialized();
    final recipes = _recipeCache[emoji];
    return recipes?.isNotEmpty == true ? recipes!.first : null;
  }
}