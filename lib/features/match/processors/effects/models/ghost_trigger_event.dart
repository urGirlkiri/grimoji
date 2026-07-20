import 'package:grimoji/features/match/models/coordinate.dart';

class GhostTriggerEvent {
  final TileCoordinate origin;
  final bool isBomb;
  final TileCoordinate? bombOrigin;

  GhostTriggerEvent({
    required this.origin,
    this.isBomb = false,
    this.bombOrigin,
  });
}
