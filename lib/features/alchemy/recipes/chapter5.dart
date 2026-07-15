import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

final List<Recipe> chapter5Recipes = [
  Recipe(ingredient: Emojis.droplet, requiredAmount: 4, yields: Emojis.testTube),
  Recipe(ingredient: Emojis.testTube, requiredAmount: 3, yields: Emojis.crystalBall),
  Recipe(ingredient: Emojis.crystalBall, requiredAmount: 3, yields: Emojis.gemStone),
  Recipe(ingredient: Emojis.gemStone, requiredAmount: 3, yields: Emojis.wand),
  Recipe(ingredient: Emojis.wand, requiredAmount: 4, yields: Emojis.sparkles),

  Recipe(ingredient: Emojis.cloud, requiredAmount: 4, yields: Emojis.rainbow),
  Recipe(ingredient: Emojis.rainbow, requiredAmount: 3, yields: Emojis.star),
  Recipe(ingredient: Emojis.star, requiredAmount: 3, yields: Emojis.glowingStar),
  Recipe(ingredient: Emojis.glowingStar, requiredAmount: 3, yields: Emojis.comet),
  Recipe(ingredient: Emojis.comet, requiredAmount: 4, yields: Emojis.ringedPlanet),
  Recipe(ingredient: Emojis.ringedPlanet, requiredAmount: 3, yields: Emojis.milkyWay),

  Recipe(ingredient: Emojis.nerdFace, requiredAmount: 3, yields: Emojis.lightBulb),
  Recipe(ingredient: Emojis.lightBulb, requiredAmount: 4, yields: Emojis.rocket),
  Recipe(ingredient: Emojis.rocket, requiredAmount: 3, yields: Emojis.flyingSaucer),
  Recipe(ingredient: Emojis.flyingSaucer, requiredAmount: 3, yields: Emojis.alienMonster),
  Recipe(ingredient: Emojis.alienMonster, requiredAmount: 4, yields: Emojis.alien), 

  Recipe(ingredient: Emojis.admissionTickets, requiredAmount: 3, yields: Emojis.die),
  Recipe(ingredient: Emojis.die, requiredAmount: 4, yields: Emojis.slotMachine),
  Recipe(ingredient: Emojis.slotMachine, requiredAmount: 3, yields: Emojis.onehundred),
];