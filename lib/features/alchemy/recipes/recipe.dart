import 'package:grimoji/config/emojis.dart';

class Recipe {
  final GameEmoji ingredient;
  final int requiredAmount;
  final GameEmoji yields;

  const Recipe({
    required this.ingredient,
    required this.requiredAmount,
    required this.yields,
  });

  String get id => '${ingredient.visual}_${requiredAmount}_${yields.visual}';
}
