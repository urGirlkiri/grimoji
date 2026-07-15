import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

final List<Recipe> chapter2Recipes = [
  Recipe(ingredient: Emojis.bug, requiredAmount: 4, yields: Emojis.spider),
  Recipe(ingredient: Emojis.spider, requiredAmount: 4, yields: Emojis.bat),
  Recipe(ingredient: Emojis.biohazard, requiredAmount: 4, yields: Emojis.snake),
  Recipe(ingredient: Emojis.snake, requiredAmount: 4, yields: Emojis.lizard),
  Recipe(ingredient: Emojis.lizard, requiredAmount: 4, yields: Emojis.tRex),

  Recipe(ingredient: Emojis.evergreenTree, requiredAmount: 4, yields: Emojis.fallenLeaf),
  Recipe(ingredient: Emojis.fallenLeaf, requiredAmount: 4, yields: Emojis.rock),
  Recipe(ingredient: Emojis.leafyGreen, requiredAmount: 3, yields: Emojis.herb),
  Recipe(ingredient: Emojis.plant, requiredAmount: 3, yields: Emojis.redApple),

  Recipe(ingredient: Emojis.crab, requiredAmount: 4, yields: Emojis.lobster),
  Recipe(ingredient: Emojis.lobster, requiredAmount: 3, yields: Emojis.scorpion),
  Recipe(ingredient: Emojis.testTube, requiredAmount: 3, yields: Emojis.bottleWithPoppingCork),
  Recipe(ingredient: Emojis.clinkingBeerMugs, requiredAmount: 3, yields: Emojis.bubbles),

  Recipe(ingredient: Emojis.cursing, requiredAmount: 4, yields: Emojis.rage),
  Recipe(ingredient: Emojis.poop, requiredAmount: 3, yields: Emojis.sick),
  Recipe(ingredient: Emojis.sick, requiredAmount: 4, yields: Emojis.stethoscope),
  Recipe(ingredient: Emojis.eye, requiredAmount: 3, yields: Emojis.eyes),
  Recipe(ingredient: Emojis.cameraFlash, requiredAmount: 4, yields: Emojis.selfie),
  Recipe(ingredient: Emojis.wand, requiredAmount: 3, yields: Emojis.television),
  Recipe(ingredient: Emojis.kissingCat, requiredAmount: 3, yields: Emojis.heartEyesCat),

  Recipe(ingredient: Emojis.cloud, requiredAmount: 4, yields: Emojis.snowflake),
  Recipe(ingredient: Emojis.hotFace, requiredAmount: 4, yields: Emojis.melting),
];