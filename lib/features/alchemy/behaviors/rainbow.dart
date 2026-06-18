import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/models/action_type.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'behavior.dart';

class RainbowBehavior extends EmojiBehavior {
  @override
  List<BehaviorAction> onSwipedWith(int x, int y, GameEmoji targetEmoji) {
    return [
      BehaviorAction(
        type: ActionType.reactEmoji,
        x: x,
        y: y,
        emoji: Emojis.droplet,
      ),
    ];
  }
}
