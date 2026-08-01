import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/models/behavior.dart';
import 'package:grimoji/features/alchemy/behaviors/models/action_type.dart';
import 'package:grimoji/features/alchemy/behaviors/models/behavior_action.dart';

class ClownBehavior extends EmojiBehavior {
  static final emoji = Emojis.clown;

  @override
  bool get isIntrusive => true;

  final int shuffleRadius;
  int turnsSinceLastShuffle = 0;

  ClownBehavior({this.shuffleRadius = 1});

  @override
  List<BehaviorAction> onTurnEnd(int x, int y) {
    turnsSinceLastShuffle++;

    if (turnsSinceLastShuffle >= 3) {
      turnsSinceLastShuffle = 0;
      return [BehaviorAction(type: ActionType.shuffleSurrounding, x: x, y: y)];
    }
    return [];
  }
}
