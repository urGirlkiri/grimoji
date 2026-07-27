import 'package:grimoji/features/match/models/coordinate.dart';

enum GhostPowerup { none, bomb, pole }

class GhostTriggerEvent {
  final TileCoordinate origin;
  final GhostPowerup powerup;
  final TileCoordinate? powerupOrigin;
  final bool? isHorizontal;

  GhostTriggerEvent({
    required this.origin,
    this.powerup = GhostPowerup.none,
    this.powerupOrigin,
    this.isHorizontal,
  });
}
