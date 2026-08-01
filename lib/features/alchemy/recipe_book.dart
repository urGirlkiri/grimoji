import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/alchemy/reactions/models/reaction.dart';
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
import 'dart:collection';

import 'package:grimoji/features/alchemy/recipes/chapter5.dart';
import 'package:grimoji/features/alchemy/recipes/models/recipe.dart';

class RecipeBook {
  static final List<Recipe> allRecipes = [
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
  ];

  static final Map<GameEmoji, List<Recipe>> _recipeCache = {};
  static final Map<GameEmoji, Reaction> _triggerCache = {};
  static final Map<GameEmoji, List<Recipe>> _yieldCache = {};
  static final Map<GameEmoji, int> _tierCache = {};
  static List<Recipe>? _specialRecipesCache;
  static bool _isInitialized = false;

  static void _ensureInitialized() {
    if (_isInitialized) return;
    _isInitialized = true;

    for (var recipe in allRecipes) {
      _recipeCache.putIfAbsent(recipe.ingredient, () => []).add(recipe);
      _yieldCache.putIfAbsent(recipe.yields, () => []).add(recipe);
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

  static Map<GameEmoji, GameEmoji> getTransformationsForType(
    ReactionType type,
  ) {
    _ensureInitialized();
    final Map<GameEmoji, GameEmoji> allTransformations = {};
    for (final reaction in allReactions) {
      if (reaction.type == type) {
        allTransformations.addAll(reaction.transformations);
      }
    }
    return allTransformations;
  }

  static int getAoERadiusForType(ReactionType type) {
    _ensureInitialized();
    final reaction = allReactions.firstWhere(
      (r) => r.type == type,
      orElse: () =>
          Reaction(type: type, triggers: [], transformations: {}, aoeRadius: 1),
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

  static int getTier(GameEmoji emoji) {
    return _calcEmojiTier(emoji, {});
  }

  static int _calcEmojiTier(GameEmoji emoji, Set<GameEmoji> visited) {
    _ensureInitialized();

    if (_tierCache.containsKey(emoji)) {
      return _tierCache[emoji]!;
    }

    if (visited.contains(emoji)) {
      _tierCache[emoji] = 1;
      return 1;
    }

    if (!_yieldCache.containsKey(emoji)) {
      _tierCache[emoji] = 1;
      return 1;
    }

    visited.add(emoji);
    final recipes = _yieldCache[emoji]!;
    recipes.sort((a, b) => b.requiredAmount.compareTo(a.requiredAmount));
    int tier = 1 + _calcEmojiTier(recipes.first.ingredient, visited);
    _tierCache[emoji] = tier;

    return tier;
  }

  static bool isLegendary(GameEmoji emoji) {
    return getTier(emoji) >= 5;
  }

  static final Map<String, GameEmoji> _visualToEmojiCache = {};
  static final Map<GameEmoji, Map<GameEmoji, int>> _recipeChainStepsCache = {};

  static GameEmoji? emojiForVisual(String visual) {
    _ensureInitialized();
    if (_visualToEmojiCache.isEmpty) {
      for (final emoji in Emojis.all) {
        _visualToEmojiCache[emoji.visual] = emoji;
      }
    }
    return _visualToEmojiCache[visual];
  }

  static Map<GameEmoji, int> getRecipeChainSteps(GameEmoji target) {
    _ensureInitialized();
    final cached = _recipeChainStepsCache[target];
    if (cached != null) return cached;

    final steps = <GameEmoji, int>{target: 0};
    final queue = ListQueue<GameEmoji>()..add(target);

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final recipes = _yieldCache[current];
      if (recipes == null) continue;

      for (final recipe in recipes) {
        final ingredient = recipe.ingredient;
        if (!steps.containsKey(ingredient)) {
          steps[ingredient] = steps[current]! + 1;
          queue.add(ingredient);
        }
      }
    }

    _recipeChainStepsCache[target] = steps;
    return steps;
  }

  static Set<GameEmoji> getRecipeChainTo(GameEmoji target) {
    return getRecipeChainSteps(target).keys.toSet();
  }

  static GameEmoji? getRecipeYield(GameEmoji ingredient, int groupSize) {
    _ensureInitialized();
    final recipes = _recipeCache[ingredient];
    if (recipes == null || recipes.isEmpty) return null;

    for (final recipe in recipes) {
      if (groupSize >= recipe.requiredAmount) return recipe.yields;
    }
    return null;
  }

  static List<Recipe> get specialRecipes {
    _ensureInitialized();
    if (_specialRecipesCache != null) return _specialRecipesCache!;

    final specialEmojis = <GameEmoji>{Emojis.ghost, Emojis.bomb, Emojis.hole};

    for (final powerup in Powerup.all) {
      final emoji = Powerup.emojiForId(powerup.id);
      if (emoji != null) specialEmojis.add(emoji);
    }

    _specialRecipesCache = allRecipes
        .where((recipe) => specialEmojis.contains(recipe.yields))
        .toList();

    return _specialRecipesCache!;
  }
}
