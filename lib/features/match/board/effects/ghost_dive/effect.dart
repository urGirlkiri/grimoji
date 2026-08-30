import 'package:grimoji/features/match/board/effect/models/board_effect.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/processors/effects/models/ghost_trigger_event.dart';

class GhostDiveEffect extends BoardEffect {
  final TileCoordinate origin;
  final TileCoordinate target;
  final TileCoordinate? powerupOrigin;
  final GhostPowerup powerup;
  final bool? isHorizontal;

  GhostDiveEffect({
    required this.origin,
    required this.target,
    this.powerupOrigin,
    this.powerup = GhostPowerup.none,
    this.isHorizontal,
  }) : super();
}
