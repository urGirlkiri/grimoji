import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/models/action_type.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/config/emojis/index.dart';

class WheelBehavior extends EmojiBehavior {
  static const _action = BehaviorAction(type: ActionType.rollWheel);

  @override
  List<BehaviorAction> onMatched(int x, int y) => [_action];

  @override
  List<BehaviorAction> onSwipedWith(int x, int y, GameEmoji targetEmoji) => [
    _action,
  ];

  @override
  List<BehaviorAction> onTapped(int x, int y) => [_action];
}
