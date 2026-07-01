import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/models/action_type.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class DiveBehavior extends EmojiBehavior {
  static final emoji = Emojis.ghost;

  static const _action = BehaviorAction(type: ActionType.ghostDive);

  @override
  List<BehaviorAction> onMatched(int x, int y) => [_action];

  @override
  List<BehaviorAction> onTapped(int x, int y) => [_action];

  @override
  List<BehaviorAction> onBlastNearby(int x, int y, ReactionType reactionType) {
    if (reactionType == ReactionType.explosive) return [_action];
    return [];
  }
}
