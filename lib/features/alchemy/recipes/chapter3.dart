import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

const List<Recipe> chapter3Recipes = [
  Recipe(
    ingredient: Emojis.snake,
    requiredAmount: 4,
    yields: Emojis.biohazard,
  ),
  
  Recipe(
    ingredient: Emojis.chains,
    requiredAmount: 4,
    yields: Emojis.locked,
  ),

  Recipe(
    ingredient: Emojis.rock,
    requiredAmount: 5, 
    yields: Emojis.volcano,
  ),

  Recipe(
    ingredient: Emojis.metal,
    requiredAmount: 4,
    yields: Emojis.coin,
  ),

  Recipe(
    ingredient: Emojis.snake,
    requiredAmount: 4,
    yields: Emojis.crocodile,
  ),

  Recipe(
    ingredient: Emojis.crocodile,
    requiredAmount: 4,
    yields: Emojis.dragon,
  ),
];