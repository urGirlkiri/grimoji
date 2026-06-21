import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

abstract class EmojiBehavior {
  List<BehaviorAction> onTurnEnd(int x, int y) => [];

  List<BehaviorAction> onMatched(int x, int y) => [];

  List<BehaviorAction> onBlastNearby(int x, int y, ReactionType reactionType) =>
      [];

  List<BehaviorAction> onSwipedWith(int x, int y, GameEmoji targetEmoji) => [];

  List<BehaviorAction> onTapped(int x, int y) => [];

  bool hasSwipeBehavior(int x, int y, GameEmoji targetEmoji) {
    return onSwipedWith(x, y, targetEmoji).isNotEmpty;
  }
}
