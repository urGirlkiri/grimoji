import 'package:grimoji/features/match/board/effect/manager.dart';
import 'package:grimoji/features/match/board/effects/ufo/models/beam_type.dart';
import 'package:grimoji/features/match/models/coordinate.dart';

class UFOEffect extends BoardEffect {
  final List<TileCoordinate> targets;
  final List<UFOBeamType> beamTypes;
    final List<Duration> beamDelays; 

  UFOEffect({
    required this.targets,
    required this.beamTypes,
    required this.beamDelays,
  }) : super();
}
