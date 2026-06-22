import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/models/action_type.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/config/emojis/index.dart';

class ClearBehavior extends EmojiBehavior {
  final bool isHorizontal;

  ClearBehavior({required this.isHorizontal});

  BehaviorAction get _action => BehaviorAction(
        type: isHorizontal ? ActionType.clearCol : ActionType.clearRow,
      );

  @override
  List<BehaviorAction> onTapped(int x, int y) => [_action];

  @override
  List<BehaviorAction> onSwipedWith(int x, int y, GameEmoji targetEmoji) =>
      [_action];

  @override
  List<BehaviorAction> onBlastNearby(int x, int y, ReactionType reactionType) {
    if (reactionType == ReactionType.explosive) return [_action];
    return [];
  }
}
