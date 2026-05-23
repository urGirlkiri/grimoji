import 'package:grimoji/features/game/board/models/coordinate.dart';
import 'package:grimoji/features/game/model/collected_emoji.dart';
import 'package:grimoji/features/game/utils/match_detector.dart';

class CascadeStepResult {
  final List<MatchGroup> matchedGroups;
  final Set<TileCoordinate> tilesToDestroy;
  final Set<TileCoordinate> transmutedTiles;
  final List<CollectedEmoji> collectedEmojis;
  final bool hasTriggeredBombs;

  CascadeStepResult({
    required this.matchedGroups,
    required this.tilesToDestroy,
    required this.transmutedTiles,
    required this.collectedEmojis,
    required this.hasTriggeredBombs,
  });
}
