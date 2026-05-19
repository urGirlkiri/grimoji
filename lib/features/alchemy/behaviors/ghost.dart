import 'dart:math';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class GhostBehavior extends EmojiBehavior {
  static const double randomChance = 0.10; 
  
  @override
  List<BehaviorAction> onTurnEnd(int x, int y) {
    if (Random().nextDouble() < randomChance) {
      return [
        BehaviorAction(
          type: ActionType.reactEmoji,
          x: x,
          y: y,
          emoji: Emojis.bone,
        ),
      ];
    }
    return [];
  }

  @override
  List<BehaviorAction> onBlastNearby(int x, int y, ReactionType reactionType) {
    if (reactionType == ReactionType.explosive) {
      return [
        BehaviorAction(
          type: ActionType.placeEmoji,
          x: x,
          y: y,
          emoji: Emojis.ghost,
        ),
      ];
    }
    return [];
  }
}