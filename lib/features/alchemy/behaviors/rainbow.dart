import 'package:grimoji/config/emojis.dart';
import 'behavior.dart';

class RainbowBehavior extends EmojiBehavior {
  @override
  List<BehaviorAction> onSwipedWith(int x, int y, GameEmoji targetEmoji) {
    return [
      BehaviorAction(
        type: ActionType.transmuteEmoji,
        x: x,
        y: y,
        emoji: Emojis.droplet,
      ),
    ];
  }
}
