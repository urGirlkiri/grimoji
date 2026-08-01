import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/models/action_type.dart';
import 'package:grimoji/features/alchemy/behaviors/models/behavior_action.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/behaviors/models/behavior.dart';

class VirusBehavior extends EmojiBehavior {
  static final emoji = Emojis.microbe;

  @override
  bool get isIntrusive => true;

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
          emoji: emoji,
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
