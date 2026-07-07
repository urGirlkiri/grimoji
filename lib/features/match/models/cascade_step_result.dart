import 'package:grimoji/features/match/models/collected_emoji.dart';
import 'package:grimoji/features/match/models/match_group.dart';
import 'package:grimoji/features/match/types.dart';

class CascadeStepResult {
  final List<MatchGroup> matchedGroups;
  final TileSet tilesToDestroy;
  final TileSet transmutedTiles;
  final TileSet transformed;
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
