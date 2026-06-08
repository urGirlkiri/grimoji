import 'package:grimoji/config/emojis/index.dart';
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
