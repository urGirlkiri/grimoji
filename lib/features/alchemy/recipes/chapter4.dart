import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

const List<Recipe> chapter4Recipes = [
  Recipe(
    ingredient: Emojis.rainCloud,
    requiredAmount: 4,
    yields: Emojis.cloudWithLightning,
  ),

  Recipe(
    ingredient: Emojis.blackBird,
    requiredAmount: 4,
    yields: Emojis.eagle,
  ),

  Recipe(
    ingredient: Emojis.eagle,
    requiredAmount: 5,
    yields: Emojis.phoenix,
  ),

  Recipe(
    ingredient: Emojis.cloudWithLightning,
    requiredAmount: 5,
    yields: Emojis.electricity,
  ),
  Recipe(
    ingredient: Emojis.fireworks,
    requiredAmount: 4,
    yields: Emojis.collision,
  ),
  Recipe(
    ingredient: Emojis.fireworks,
    requiredAmount: 3,
    yields: Emojis.bomb,
  ),
  Recipe(
    ingredient: Emojis.babyChick,
    requiredAmount: 3,
    yields: Emojis.blackBird,
  ),
  Recipe(
    ingredient: Emojis.windFace,
    requiredAmount: 3,
    yields: Emojis.coldFace,
  ),
  Recipe(
    ingredient: Emojis.windFace,
    requiredAmount: 4,
    yields: Emojis.cloud,
  ),
];