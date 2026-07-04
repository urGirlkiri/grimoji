import 'package:grimoji/features/match/board/effects/manager.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';

class GhostDiveEffect extends BoardEffect {
  final TileCoordinate origin;
  final TileCoordinate target;

  GhostDiveEffect({required this.origin, required this.target}) : super();
}
