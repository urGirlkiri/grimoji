import 'package:grimoji/features/match/board/models/coordinate.dart';
import 'package:grimoji/features/match/model/collected_emoji.dart';
import 'package:grimoji/features/match/utils/match_detector.dart';

class CascadeStepResult {
  final List<MatchGroup> matchedGroups;
  final Set<TileCoordinate> tilesToDestroy;
  final Set<TileCoordinate> transmutedTiles;
  final Set<TileCoordinate> transformed;
  final List<CollectedEmoji> collectedEmojis;
  final bool hasTriggeredBombs;

  CascadeStepResult({
    required this.matchedGroups,
    required this.tilesToDestroy,
    required this.transmutedTiles,
    required this.transformed,
    required this.collectedEmojis,
    required this.hasTriggeredBombs,
  });
}
