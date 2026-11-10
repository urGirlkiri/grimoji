import 'package:grimoji/features/match/board/effects/ufo/models/beam_type.dart';
import 'package:grimoji/features/match/models/coordinate.dart';

class UFOPlan {
  final List<TileCoordinate> targets;
  final List<UFOBeamType> beamTypes;
  final List<Duration> beamDelays;
  final List<String> tileIds;

  const UFOPlan({
    required this.targets,
    required this.beamTypes,
    required this.beamDelays,
    this.tileIds = const [],
  });
}
