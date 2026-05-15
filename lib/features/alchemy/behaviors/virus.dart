import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'behavior.dart';

class VirusBehavior extends EmojiBehavior {
  int turnsSinceLastMultiplication = 0;

  @override
  List<BehaviorAction> onTurnEnd(int x, int y) {
    turnsSinceLastMultiplication++;
    
    if (turnsSinceLastMultiplication >= 3) {
      turnsSinceLastMultiplication = 0;
      return [
        BehaviorAction(
          type: ActionType.placeEmoji,
          x: x,
          y: y,
          emoji: Emojis.bug,
        ),
      ];
    }
    return [];
  }

  @override
  List<BehaviorAction> onBlastNearby(int x, int y, ReactionType reactionType) {
    if (reactionType == ReactionType.freezing) {
      turnsSinceLastMultiplication = -5; 
    }
    return [];
  }
}