import 'package:grimoji/features/match/board/effect/models/board_effect.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/processors/effects/models/ghost_trigger_event.dart';

class GhostDiveEffect extends BoardEffect {
  final TileCoordinate origin;
  final TileCoordinate target;
  final TileCoordinate? powerupOrigin;
  final GhostPowerup powerup;
  final bool? isPoleHorizontal;
  final bool isHaunting;
  final List<TileCoordinate> wanderPath;

  GhostDiveEffect({
    required this.origin,
    required this.target,
    this.powerupOrigin,
    this.powerup = GhostPowerup.none,
    this.isPoleHorizontal,
    this.isHaunting = false,
    this.wanderPath = const [],
  }) : super();
}
