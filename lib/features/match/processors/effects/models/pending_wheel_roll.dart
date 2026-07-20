import 'package:grimoji/features/match/board/effects/wheel_roll/effect.dart';
import 'package:grimoji/features/match/models/coordinate.dart';

class PendingWheelRoll {
  final RollEffect effect;
  final TileCoordinate origin;

  PendingWheelRoll({required this.effect, required this.origin});
}
