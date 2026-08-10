import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/models/behavior.dart';
import 'package:grimoji/features/alchemy/behaviors/models/action_type.dart';
import 'package:grimoji/features/alchemy/behaviors/models/behavior_action.dart';

class BombBehavior extends EmojiBehavior {
  static final emoji = Emojis.bomb;

  @override
  List<BehaviorAction> onSwipedWith(int x, int y, GameEmoji targetEmoji) {
    if (targetEmoji == emoji) {
      return [BehaviorAction(type: ActionType.bomb, x: x, y: y)];
    }
    return [];
  }
}
