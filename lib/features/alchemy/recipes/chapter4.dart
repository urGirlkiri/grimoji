import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/recipes/models/recipe.dart';

final List<Recipe> chapter4Recipes = [
  
  Recipe(ingredient: Emojis.babyChick, requiredAmount: 3, yields: Emojis.blackBird),
  Recipe(ingredient: Emojis.blackBird, requiredAmount: 4, yields: Emojis.eagle),
  Recipe(ingredient: Emojis.eagle, requiredAmount: 3, yields: Emojis.peacock),
  Recipe(ingredient: Emojis.eagle, requiredAmount: 4, yields: Emojis.phoenix),
  
  Recipe(ingredient: Emojis.cloud, requiredAmount: 3, yields: Emojis.windFace),
  Recipe(ingredient: Emojis.cloud, requiredAmount: 4, yields: Emojis.faceInClouds),
  Recipe(ingredient: Emojis.rainCloud, requiredAmount: 4, yields: Emojis.cloudWithLightning),
  Recipe(ingredient: Emojis.cloudWithLightning, requiredAmount: 4, yields: Emojis.electricity),
  Recipe(ingredient: Emojis.electricity, requiredAmount: 4, yields: Emojis.warning),

  Recipe(ingredient: Emojis.windFace, requiredAmount: 3, yields: Emojis.coldFace),
  Recipe(ingredient: Emojis.windFace, requiredAmount: 4, yields: Emojis.cloud), 
  Recipe(ingredient: Emojis.coldFace, requiredAmount: 3, yields: Emojis.iceCream),
  Recipe(ingredient: Emojis.iceCream, requiredAmount: 3, yields: Emojis.coldFace), 
  
  Recipe(ingredient: Emojis.tornado, requiredAmount: 4, yields: Emojis.cyclone),
  Recipe(ingredient: Emojis.cyclone, requiredAmount: 3, yields: Emojis.tornado), 

  Recipe(ingredient: Emojis.metal, requiredAmount: 3, yields: Emojis.laptopComputer),
  Recipe(ingredient: Emojis.laptopComputer, requiredAmount: 3, yields: Emojis.robot),
  
  Recipe(ingredient: Emojis.fireworks, requiredAmount: 3, yields: Emojis.bomb),
  Recipe(ingredient: Emojis.fireworks, requiredAmount: 4, yields: Emojis.collision),

  Recipe(ingredient: Emojis.herb, requiredAmount: 3, yields: Emojis.leafyGreen),
  Recipe(ingredient: Emojis.ocean, requiredAmount: 3, yields: Emojis.salt),
];