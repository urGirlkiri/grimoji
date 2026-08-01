import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/models/behavior.dart';
import 'package:grimoji/features/alchemy/behaviors/models/action_type.dart';
import 'package:grimoji/features/alchemy/behaviors/models/behavior_action.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class SwallowBehavior extends EmojiBehavior {
  static final emoji = Emojis.hole;

  @override
  List<BehaviorAction> onSwipedWith(int x, int y, GameEmoji targetEmoji) {
    if (targetEmoji == emoji) {
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
  List<BehaviorAction> onTapped(int x, int y) {
    return [
      const BehaviorAction(type: ActionType.consumeRandomType, emoji: null),
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
