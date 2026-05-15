import 'package:grimoji/config/emojis.dart';

enum ReactionType { 
  explosive,
  freezing,
  burning,
}

class Reaction {
  final ReactionType type;
  
  final List<GameEmoji> triggers;
  
  final Map<GameEmoji, GameEmoji> transformations;
  
  final int aoeRadius;

  Reaction({
    required this.type,
    required this.triggers,
    required this.transformations,
    this.aoeRadius = 1,
  });
}