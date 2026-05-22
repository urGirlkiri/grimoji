import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

const List<Recipe> chapter2Recipes = [
  Recipe(
    ingredient: Emojis.bug,
    requiredAmount: 4,
    yields: Emojis.spider,
  ),
  Recipe(
    ingredient: Emojis.bug,
    requiredAmount: 5,
    yields: Emojis.snake,
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
  Recipe(
    ingredient: Emojis.evergreenTree,
    requiredAmount: 4,
    yields: Emojis.fallenLeaf,
  ),

  Recipe(
    ingredient: Emojis.leafyGreen,
    requiredAmount: 3,
    yields: Emojis.herb,
  ),
  Recipe(
    ingredient: Emojis.hotFace,
    requiredAmount: 5,
    yields: Emojis.melting,
  ),
  Recipe(
    ingredient: Emojis.kissingCat,
    requiredAmount: 3,
    yields: Emojis.heartEyesCat,
  ),
  Recipe(
    ingredient: Emojis.clinkingBeerMugs,
    requiredAmount: 3,
    yields: Emojis.bubbles,
  ),
  Recipe(
    ingredient: Emojis.plant,
    requiredAmount: 3,
    yields: Emojis.redApple,
  ),
];