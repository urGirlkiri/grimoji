import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/models/action_type.dart';

class BehaviorAction {
  final ActionType type;
  final int x;
  final int y;
  final GameEmoji? emoji;

  const BehaviorAction({
    required this.type,
    required this.x,
    required this.y,
    this.emoji,
  });
}
