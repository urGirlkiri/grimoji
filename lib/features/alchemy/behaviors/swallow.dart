import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/models/action_type.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class SwallowBehavior extends EmojiBehavior {
  static final triggerEmoji = Emojis.hole;

  @override
  List<BehaviorAction> onSwipedWith(int x, int y, GameEmoji targetEmoji) {
    if (targetEmoji == triggerEmoji) {
      return [
        const BehaviorAction(
          type: ActionType.consumeAllOfType,
          emoji: null,
          x: null,
          y: null,
        ),
      ];
    }

    return [
      BehaviorAction(type: ActionType.consumeAllOfType, emoji: targetEmoji),
    ];
  }

  @override
  List<BehaviorAction> onBlastNearby(int x, int y, ReactionType reactionType) {
    if (reactionType == ReactionType.explosive) {
      return [
        const BehaviorAction(type: ActionType.consumeRandomType, emoji: null),
      ];
    }
    return [];
  }
}
