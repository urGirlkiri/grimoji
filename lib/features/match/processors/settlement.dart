import 'package:grimoji/features/match/board/models/board_region.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/match/detectors/match.dart';
import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/state.dart';
import 'package:grimoji/features/match/types.dart';
import 'package:grimoji/features/match/utils/manager.dart';

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
    BoardRegion toDestroy, {
    bool clearFlyingFlags = false,
  }) async {
    final deltas = boardManager.applyGravity(toDestroy.coordinates);

    engine.initializeBehaviors();

    if (clearFlyingFlags) boardManager.clearAllFlyingFlags();
    if (!await _delay(postFallSettleDelay)) return null;

    boardManager.triggerInitialFall();
    if (!await _delay(fallDuration)) return null;

    return deltas;
  }

  Future<GravityResult?> afterCascade(
    BoardRegion toDestroy,
    BoardRegion toCollect,
    List<MatchGroup> matchedGroups,
  ) async {
    final BoardRegion matches = matchedGroups.combinedRegion;

    bool hasAoE = toDestroy.coordinates.any(
      (coord) => !matches.contains(coord),
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

    final BoardRegion alltoDestroy = toDestroy.merge(toCollect);

    return await settleBoard(alltoDestroy, clearFlyingFlags: true);
  }

  Future<bool> afterDetonation(BoardRegion blasttoDestroy) async {
    if (await settleBoard(blasttoDestroy, clearFlyingFlags: true) == null) {
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
