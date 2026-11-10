import 'package:flutter/foundation.dart';
import 'package:grimoji/features/match/board/effect/models/board_effect.dart';
import 'package:grimoji/features/match/board/effects/ufo/models/beam_type.dart';
import 'package:grimoji/features/match/models/coordinate.dart';

class UFOEffect extends BoardEffect {
  final List<TileCoordinate> targets;
  final List<UFOBeamType> beamTypes;
  final List<Duration> beamDelays;
  final List<String> tileIds;
  VoidCallback? onExtend;

  UFOEffect({
    required this.targets,
    required this.beamTypes,
    required this.beamDelays,
    this.tileIds = const [],
  }) : super();
}
