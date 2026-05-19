import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

const List<Recipe> chapter1Recipes = [
  Recipe(
    ingredient: Emojis.leafyGreen,
    requiredAmount: 4,
    yields: Emojis.mushroom,
  ),

  Recipe(
    ingredient: Emojis.fire,
    requiredAmount: 4,
    yields: Emojis.bomb,
  ),

  Recipe(
    ingredient: Emojis.skull,
    requiredAmount: 4,
    yields: Emojis.bone,
  ),

  Recipe(
    ingredient: Emojis.bone,
    requiredAmount: 5,
    yields: Emojis.anatomicalHeart,
  ),
];