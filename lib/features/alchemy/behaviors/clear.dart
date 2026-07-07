import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/models/action_type.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/utils/manager.dart';

class ClearBehavior extends EmojiBehavior {
  static final emoji = Emojis.barberPole;
  static final waveTrigger = Emojis.smile;

  final bool isHorizontal;

  ClearBehavior({required this.isHorizontal});

  BehaviorAction get _action => BehaviorAction(
    type: isHorizontal ? ActionType.clearRow : ActionType.clearCol,
  );

  @override
  List<BehaviorAction> onTapped(int x, int y) => [_action];

  @override
  List<BehaviorAction> onSwipedWith(int x, int y, GameEmoji targetEmoji) {
    if (targetEmoji == waveTrigger) {
      return _build3Clears(x, y); 
    }
    
    if (targetEmoji == emoji) {
      return _buildCross(); 
    }
    
    return [_action]; 
  }

  List<BehaviorAction> _buildCross() {
    return [
      const BehaviorAction(type: ActionType.clearRow),
      const BehaviorAction(type: ActionType.clearCol),
    ];
  }

  List<BehaviorAction> _build3Clears(int x, int y) {
    final actions = <BehaviorAction>[];

    if (isHorizontal) {
      final rows = _threeConsecutives(x, BoardManager.rows);
      for (final r in rows) {
        actions.add(BehaviorAction(type: ActionType.clearRow, x: r, y: y));
      }
    } else {
      final cols = _threeConsecutives(y, BoardManager.cols);
      for (final c in cols) {
        actions.add(BehaviorAction(type: ActionType.clearCol, x: x, y: c));
      }
    }

    return actions;
  }

  List<int> _threeConsecutives(int center, int max) {
    if (center == 0) return [0, 1, 2];
    if (center == max - 1) return [max - 1, max - 2, max - 3];
    return [center - 1, center, center + 1];
  }
}