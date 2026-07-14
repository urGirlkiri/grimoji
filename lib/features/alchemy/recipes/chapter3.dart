import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

final List<Recipe> chapter3Recipes = [
  Recipe(ingredient: Emojis.linkedPaperclips, requiredAmount: 4, yields: Emojis.brokenChain),
  Recipe(ingredient: Emojis.brokenChain, requiredAmount: 4, yields: Emojis.chains),
  Recipe(ingredient: Emojis.chains, requiredAmount: 4, yields: Emojis.locked),
  Recipe(ingredient: Emojis.locked, requiredAmount: 4, yields: Emojis.openLock),

  Recipe(ingredient: Emojis.snake, requiredAmount: 4, yields: Emojis.crocodile),
  Recipe(ingredient: Emojis.crocodile, requiredAmount: 4, yields: Emojis.dragon),

  Recipe(ingredient: Emojis.splatter, requiredAmount: 4, yields: Emojis.biohazard),
  Recipe(ingredient: Emojis.biohazard, requiredAmount: 3, yields: Emojis.radioactive),
  Recipe(ingredient: Emojis.blackHeart, requiredAmount: 4, yields: Emojis.hole),

  Recipe(ingredient: Emojis.rock, requiredAmount: 3, yields: Emojis.mountain),
  Recipe(ingredient: Emojis.rock, requiredAmount: 4, yields: Emojis.debris),
  Recipe(ingredient: Emojis.fireHeart, requiredAmount: 4, yields: Emojis.volcano),
  Recipe(ingredient: Emojis.leaflessTree, requiredAmount: 4, yields: Emojis.derelictHouse),

  Recipe(ingredient: Emojis.shield, requiredAmount: 4, yields: Emojis.metal),
  Recipe(ingredient: Emojis.metal, requiredAmount: 4, yields: Emojis.coin),
  Recipe(ingredient: Emojis.treasure, requiredAmount: 3, yields: Emojis.crown),

  Recipe(ingredient: Emojis.skull, requiredAmount: 3, yields: Emojis.ogre),
  Recipe(ingredient: Emojis.skull, requiredAmount: 4, yields: Emojis.ghost),
  Recipe(ingredient: Emojis.moonFaceNew, requiredAmount: 4, yields: Emojis.moai),
];