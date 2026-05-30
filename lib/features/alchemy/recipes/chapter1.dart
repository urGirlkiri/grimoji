import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';

const List<Recipe> chapter1Recipes = [
  Recipe(ingredient: Emojis.droplet, requiredAmount: 3, yields: Emojis.ocean),
  Recipe(
    ingredient: Emojis.leafyGreen,
    requiredAmount: 4,
    yields: Emojis.mushroom,
  ),

  Recipe(
    ingredient: Emojis.leaflessTree,
    requiredAmount: 3,
    yields: Emojis.fire,
  ),
  Recipe(
    ingredient: Emojis.fire,
    requiredAmount: 4,
    yields: Emojis.bomb,
  ),

  Recipe(
    ingredient: Emojis.poulrofietryLeg,
    requiredAmount: 3,
    yields: Emojis.bone,
  ),
  Recipe(
    ingredient: Emojis.worm,
    requiredAmount: 3,
    yields: Emojis.bug,
  ),



  Recipe(
    ingredient: Emojis.bone,
    requiredAmount: 3,
    yields: Emojis.poultryLeg,
  ),
  Recipe(
    ingredient: Emojis.bone,
    requiredAmount: 4,
    yields: Emojis.skull,
  ),

  Recipe(
    ingredient: Emojis.bone,
    requiredAmount: 5,
    yields: Emojis.anatomicalHeart,
  ),
];