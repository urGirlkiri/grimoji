import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/models/behavior.dart';
import 'package:grimoji/features/alchemy/behaviors/models/action_type.dart';
import 'package:grimoji/features/alchemy/behaviors/models/behavior_action.dart';

class DiveBehavior extends EmojiBehavior {
  static final emoji = Emojis.ghost;
  static final bombTrigger = Emojis.bomb;
  static final poleTrigger = Emojis.barberPole;

  static const _action = BehaviorAction(type: ActionType.ghostDive);

  @override
  List<BehaviorAction> onMatched(int x, int y) => [_action];

  @override
  List<BehaviorAction> onTapped(int x, int y) => [_action];

  @override
  List<BehaviorAction> onSwipedWith(int x, int y, GameEmoji targetEmoji) {
    if (targetEmoji == emoji) {
      return [BehaviorAction(type: ActionType.ghostDive, x: x, y: y)];
    }
    if (targetEmoji == bombTrigger) {
      return [
        BehaviorAction(
          type: ActionType.ghostDive,
          x: x,
          y: y,
          emoji: bombTrigger,
        ),
      ];
    }
    if (targetEmoji == poleTrigger) {
      return [
        BehaviorAction(
          type: ActionType.ghostDive,
          x: x,
          y: y,
          emoji: poleTrigger,
        ),
      ];
    }
    return [];
  }
}
