import 'dart:math';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/models/action_type.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class PrankBehavior extends EmojiBehavior {
  static final emoji = Emojis.impSmile;
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

  @override
  List<BehaviorAction> onBlastNearby(int x, int y, ReactionType reactionType) {
    if (reactionType == ReactionType.explosive) {
      return [
        BehaviorAction(
          type: ActionType.placeEmoji,
          x: x,
          y: y,
          emoji: Emojis.poop,
        ),
      ];
    }
    return [];
  }
}
