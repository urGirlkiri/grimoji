import 'dart:math';
import 'package:grimoji/config/emojis.dart';
import 'behavior.dart';

class GhostBehavior extends EmojiBehavior {
  static const double randomChance = 0.10; 
  
  @override
  List<BehaviorAction> onTurnEnd(int x, int y) {
    if (Random().nextDouble() < randomChance) {
      return [
        BehaviorAction(
          type: ActionType.reactEmoji,
          x: x,
          y: y,
          emoji: Emojis.bone,
        ),
      ];
    }
    return [];
  }
}