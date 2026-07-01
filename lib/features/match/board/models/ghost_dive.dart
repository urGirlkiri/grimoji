import 'package:uuid/uuid.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';

class GhostDiveEffect {
  final String id;
  final TileCoordinate origin;
  final TileCoordinate target;

  GhostDiveEffect({
    required this.origin,
    required this.target,
    String? id,
  }) : id = id ?? const Uuid().v4();
}
