import 'package:grimoji/config/emojis.dart';

enum RecipeType {
  merge,  
  
  base   
}

class Recipe {
  final GameEmoji ingredient;
  final int requiredAmount;
  final GameEmoji? yields;
  final RecipeType type;

  const Recipe({
    required this.ingredient,
    required this.requiredAmount,
    this.yields,
    required this.type,
  });
}
