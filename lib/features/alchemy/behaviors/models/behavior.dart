import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/models/behavior_action.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/config/levels/game_level.dart';

abstract class EmojiBehavior {
  bool get isIntrusive => false;

  List<BehaviorAction> onTurnEnd(int x, int y) => [];

  Future<List<BehaviorAction>> onTurnEndWithBoard(
    int x,
    int y,
    List<List<Tile>> board,
    GameLevel level,
  ) async => [];

  List<BehaviorAction> onMatched(int x, int y) => [];

  List<BehaviorAction> onBlastNearby(int x, int y, ReactionType reactionType) =>
      [];

  List<BehaviorAction> onSwipedWith(int x, int y, GameEmoji targetEmoji) => [];

  List<BehaviorAction> onTapped(int x, int y) => [];
}
