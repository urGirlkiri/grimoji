import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/detectors/match.dart';
import 'package:grimoji/features/match/models/match_group.dart';
import 'package:grimoji/features/match/models/tile.dart';

enum SwipeResult { match, specialBehavior, invalid }

class SwipeDecision {
  final SwipeResult type;
  final List<MatchGroup> matches;
  final List<BehaviorAction> actions;
  final int triggerRow;
  final int triggerCol;

  SwipeDecision({
    required this.type,
    this.matches = const [],
    this.actions = const [],
    this.triggerRow = 0,
    this.triggerCol = 0,
  });
}

class SwipeDetector {
  static SwipeDecision evaluate({
    required List<List<Tile>> grid,
    required TileCoordinate dCoord,
    required TileCoordinate tCoord,
    required List<BehaviorAction> Function(Tile, int, int, GameEmoji)
    getSwipeBehaviors,
    required bool Function(Tile, int, int, GameEmoji) hasSwipeBehavior,
    bool quickCheckOnly = false,
  }) {
    final tileD = grid[dCoord.row][dCoord.col];
    final tileT = grid[tCoord.row][tCoord.col];

    final hasBehaviorD = hasSwipeBehavior.call(
      tileT,
      dCoord.row,
      dCoord.col,
      tileD.emoji,
    );

    final hasBehaviorT = hasSwipeBehavior.call(
      tileD,
      tCoord.row,
      tCoord.col,
      tileT.emoji,
    );

    if (hasBehaviorD || hasBehaviorT) {
      if (quickCheckOnly) {
        return SwipeDecision(type: SwipeResult.specialBehavior);
      }

      final actionsD = getSwipeBehaviors(
        tileT,
        dCoord.row,
        dCoord.col,
        tileD.emoji,
      );
      final actionsT = getSwipeBehaviors(
        tileD,
        tCoord.row,
        tCoord.col,
        tileT.emoji,
      );
      return SwipeDecision(
        type: SwipeResult.specialBehavior,
        actions: [...actionsD, ...actionsT],
      );
    }

    _tempSwap(grid, dCoord, tCoord);

    SwipeDecision decision;

    if (quickCheckOnly) {
      final hasMatch =
          MatchDetector.hasMatchAt(grid, dCoord.row, dCoord.col) ||
          MatchDetector.hasMatchAt(grid, tCoord.row, tCoord.col);

      decision = hasMatch
          ? SwipeDecision(type: SwipeResult.match)
          : SwipeDecision(type: SwipeResult.invalid);
    } else {
      final matchedGroups = MatchDetector.findMatchedGroups(grid);
      decision = matchedGroups.isNotEmpty
          ? SwipeDecision(type: SwipeResult.match, matches: matchedGroups)
          : SwipeDecision(type: SwipeResult.invalid);
    }

    _tempSwap(grid, dCoord, tCoord);

    return decision;
  }

  static void _tempSwap(
    List<List<Tile>> grid,
    TileCoordinate a,
    TileCoordinate b,
  ) {
    final temp = grid[a.row][a.col];
    grid[a.row][a.col] = grid[b.row][b.col];
    grid[b.row][b.col] = temp;
  }
}
