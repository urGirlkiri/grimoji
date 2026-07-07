import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/state.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/detectors/match.dart';

class CascadeProcessor {
  final GameEngine engine;
  final GameState state;

  CascadeProcessor({required this.engine, required this.state});

  Future<bool> executeCascade(
    List<MatchGroup> groups,
    TileCoordinate target,
  ) async {
    final result = engine.processCascadeStep(
      matchedGroups: groups,
      targetCoordinate: target,
      isFirstMatch: false,
    );
    return result.tilesToDestroy.isNotEmpty ||
        result.transmutedTiles.isNotEmpty ||
        result.transformed.isNotEmpty ||
        result.collectedEmojis.isNotEmpty ||
        result.hasTriggeredBombs;
  }
}
