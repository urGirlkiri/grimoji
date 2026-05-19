import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

const List<Recipe> chapter2Recipes = [
  Recipe(
    ingredient: Emojis.bug,
    requiredAmount: 4,
    yields: Emojis.spider,
  ),

  Recipe(
    ingredient: Emojis.spider,
    requiredAmount: 4,
    yields: Emojis.bat,
  ),

  Recipe(
    ingredient: Emojis.cloud,
    requiredAmount: 4,
    yields: Emojis.snowflake,
  ),

  Recipe(
    ingredient: Emojis.fallenLeaf,
    requiredAmount: 4,
    yields: Emojis.rock,
  ),
];