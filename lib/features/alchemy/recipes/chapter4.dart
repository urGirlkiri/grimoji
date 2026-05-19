import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

const List<Recipe> chapter4Recipes = [
  Recipe(
    ingredient: Emojis.windFace,
    requiredAmount: 4,
    yields: Emojis.cloudWithLightning,
  ),
  
  Recipe(
    ingredient: Emojis.cloudWithLightning,
    requiredAmount: 4,
    yields: Emojis.tornado,
  ),

  Recipe(
    ingredient: Emojis.blackBird,
    requiredAmount: 4,
    yields: Emojis.eagle,
  ),
];