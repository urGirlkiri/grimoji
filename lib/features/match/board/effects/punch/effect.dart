import 'package:grimoji/features/match/board/effect/manager.dart';
import 'package:grimoji/features/match/models/coordinate.dart';

class PunchEffect extends BoardEffect {
  final TileCoordinate target;

  PunchEffect({
    required this.target,
  }) : super();
}
