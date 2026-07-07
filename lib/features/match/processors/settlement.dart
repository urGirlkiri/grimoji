import 'package:grimoji/features/match/board/models/coordinate.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/match/detectors/match.dart';
import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/state.dart';
import 'package:grimoji/features/match/utils/manager.dart';

typedef GravityResult = ({Set<int> cols, Set<int> rows});

class SettlementProcessor {
  final GameEngine engine;
  final GameState state;
  final BoardManager boardManager;

  SettlementProcessor({
    required this.engine,
    required this.state,
    required this.boardManager,
  });

  Future<GravityResult?> settleBoard(
    Set<TileCoordinate> destroyed, {
    bool clearFlyingFlags = false,
  }) async {
    final deltas = boardManager.applyGravity(destroyed);
  
    engine.initializeBehaviors();
  
    if (clearFlyingFlags) boardManager.clearAllFlyingFlags();
    if (!await _delay(postFallSettleDelay)) return null;

    boardManager.triggerInitialFall();
    if (!await _delay(fallDuration)) return null;

    return deltas;
  }

  Future<GravityResult?> afterCascade(
    Set<TileCoordinate> tilesToDestroy,
    Set<TileCoordinate> flyingTargets,
    List<MatchGroup> matchedGroups,
  ) async {
    final Set<TileCoordinate> matches = matchedGroups
        .expand((g) => g.coordinates)
        .toSet();

    bool hasAoE = tilesToDestroy.any(
      (coord) => !matches.any((c) => c.row == coord.row && c.col == coord.col),
    );
    bool hasTransmutations = engine.grid.any(
      (row) => row.any((t) => t.isTransmuting),
    );

    if (hasAoE || hasTransmutations) {
      await Future.delayed(matchFreezeDuration);
      boardManager.clearTransmutingFlags();
    } else {
      await Future.delayed(emptyTransmuteDelay);
    }

    final Set<TileCoordinate> allDestroyed = {
      ...tilesToDestroy,
      ...flyingTargets,
    };

    return await settleBoard(allDestroyed, clearFlyingFlags: true);
  }

  Future<bool> afterDetonation(Set<TileCoordinate> blastDestroyed) async {
    if (await settleBoard(blastDestroyed, clearFlyingFlags: true) == null) {
      return false;
    }
    engine.processPendingBlasts();
    return true;
  }

  Future<bool> _delay(Duration duration) async {
    state.updateUI();
    await Future.delayed(duration);
    return !state.isDisposed;
  }
}
