import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

const List<Recipe> chapter5Recipes = [
  Recipe(
    ingredient: Emojis.sparkles,
    requiredAmount: 3,
    yields: Emojis.star,
  ),
  
  Recipe(
    ingredient: Emojis.star,
    requiredAmount: 3,
    yields: Emojis.glowingStar,
  ),

  Recipe(
    ingredient: Emojis.glowingStar,
    requiredAmount: 2,
    yields: Emojis.comet,
  ),

  Recipe(
    ingredient: Emojis.crystalBall,
    requiredAmount: 1,
    yields: Emojis.die,
  ),

  Recipe(
    ingredient: Emojis.eagle,
    requiredAmount: 5,
    yields: Emojis.phoenix,
  ),
];