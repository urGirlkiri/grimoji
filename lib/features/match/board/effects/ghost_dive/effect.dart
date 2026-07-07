import 'package:grimoji/features/match/board/effect/manager.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';

class GhostDiveEffect extends BoardEffect {
  final TileCoordinate origin;
  final TileCoordinate target;
  final TileCoordinate? bombOrigin;
  final bool isBomb;

  GhostDiveEffect({
    required this.origin,
    required this.target,
    this.bombOrigin,
    this.isBomb = false,
  }) : super();
}
