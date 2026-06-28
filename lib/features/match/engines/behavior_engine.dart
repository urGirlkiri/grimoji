import 'dart:math';

import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/models/action_type.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/match/board/utils/manager.dart';
import 'package:grimoji/features/match/board/models/tile.dart';
import 'package:logging/logging.dart';

class BehaviorEngine {
  final BoardManager boardManager;
  final EmojiBehavior? Function(GameEmoji) getBehavior;
  final GameLevel level;
  final Logger _log = Logger('BehaviorEngine');

  final List<({Tile tile, int x, int y, ReactionType reactionType})>
  _pendingBlasts = [];

  bool get hasPendingBlastBehaviors => _pendingBlasts.isNotEmpty;

  BehaviorEngine({
    required this.boardManager,
    required this.getBehavior,
    required this.level,
  });

  void initializeBehavior(Tile tile) {
    final behavior = getBehavior(tile.emoji);
    if (behavior != null) {
      tile.behavior = behavior;
    }
  }

  void processTurnEndBehaviors() {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        final tile = boardManager.gridTiles[r][c];
        if (tile.behavior != null) {
          final actions = tile.behavior!.onTurnEnd(r, c);
          executeBehaviorActions(actions, r, c);
        }
      }
    }
  }

  void executeBehaviorActions(
    List<BehaviorAction> actions,
    int centerX,
    int centerY,
  ) {
    for (final action in actions) {
      switch (action.type) {
        case ActionType.placeEmoji:
          final target = boardManager.findAdjacentEmptyTile(centerX, centerY);
          if (target != null && action.emoji != null) {
            boardManager.gridTiles[target.x][target.y].emoji = action.emoji!;
            initializeBehavior(boardManager.gridTiles[target.x][target.y]);
          }
          break;

        case ActionType.reactEmoji:
          final target = boardManager.findAdjacentFilledTile(centerX, centerY);
          if (target != null && action.emoji != null) {
            boardManager.gridTiles[target.x][target.y].emoji = action.emoji!;
            boardManager.gridTiles[target.x][target.y].clearBehavior();
          }
          break;

        case ActionType.consumeAllOfType:
          boardManager.gridTiles[centerX][centerY].isSwallowTrigger = true;
          boardManager.gridTiles[centerX][centerY].isSwallowTarget = true;

          for (int r = 0; r < BoardManager.rows; r++) {
            for (int c = 0; c < BoardManager.cols; c++) {
              final tile = boardManager.gridTiles[r][c];
              if (action.emoji == null || tile.emoji == action.emoji) {
                tile.isSwallowTarget = true;
              }
            }
          }
          break;

        case ActionType.doNothing:
          break;

        case ActionType.consumeRandomType:
          _log.info('Triggering random consumption');

          final emojisOnBoard = <GameEmoji>{};
          for (int r = 0; r < BoardManager.rows; r++) {
            for (int c = 0; c < BoardManager.cols; c++) {
              if (r == centerX && c == centerY) continue;
              emojisOnBoard.add(boardManager.gridTiles[r][c].emoji);
            }
          }

          boardManager.gridTiles[centerX][centerY].isSwallowTrigger = true;
          boardManager.gridTiles[centerX][centerY].isSwallowTarget = true;

          if (emojisOnBoard.isEmpty) {
            break;
          }

          final random = Random();
          final randomEmoji = emojisOnBoard.elementAt(
            random.nextInt(emojisOnBoard.length),
          );
          _log.info('Selected ${randomEmoji.visual} ');

          for (int r = 0; r < BoardManager.rows; r++) {
            for (int c = 0; c < BoardManager.cols; c++) {
              final tile = boardManager.gridTiles[r][c];
              if (tile.emoji == randomEmoji) {
                tile.isSwallowTarget = true;
              }
            }
          }
          break;

        case ActionType.clearRow:
          if (boardManager.gridTiles[centerX].any((t) => t.isLineClearTrigger))
            break;
          boardManager.gridTiles[centerX][centerY].isLineClearTrigger = true;
          for (int c = 0; c < BoardManager.cols; c++) {
            if (c != centerY) {
              boardManager.gridTiles[centerX][c].isLineClearTarget = true;
            }
          }
          break;

        case ActionType.clearCol:
          if (List.generate(
            BoardManager.rows,
            (r) => boardManager.gridTiles[r][centerY],
          ).any((t) => t.isLineClearTrigger))
            break;
          boardManager.gridTiles[centerX][centerY].isLineClearTrigger = true;
          for (int r = 0; r < BoardManager.rows; r++) {
            if (r != centerX) {
              boardManager.gridTiles[r][centerY].isLineClearTarget = true;
            }
          }
          break;
      }
    }
  }

  void processMatchedBehavior(Tile tile, int x, int y) {
    if (tile.behavior != null) {
      final actions = tile.behavior!.onMatched(x, y);
      if (actions.isNotEmpty) {
        executeBehaviorActions(actions, x, y);
      }
    }
  }

  void processBlastBehavior(
    Tile tile,
    int x,
    int y,
    ReactionType reactionType,
  ) {
    if (tile.behavior != null &&
        tile.behavior!.onBlastNearby(x, y, reactionType).isNotEmpty) {
      _pendingBlasts.add((tile: tile, x: x, y: y, reactionType: reactionType));
    }
  }

  void processPendingBlasts() {
    final pending = List.of(_pendingBlasts);
    _pendingBlasts.clear();
    for (final entry in pending) {
      if (entry.tile.behavior != null) {
        final actions = entry.tile.behavior!.onBlastNearby(
          entry.x,
          entry.y,
          entry.reactionType,
        );
        executeBehaviorActions(actions, entry.x, entry.y);
      }
    }
  }

  List<BehaviorAction> processSwipedWithBehavior(
    Tile tile,
    int x,
    int y,
    GameEmoji targetEmoji,
  ) {
    if (tile.behavior != null) {
      return tile.behavior!.onSwipedWith(x, y, targetEmoji);
    }

    return [];
  }

  bool hasSwipeBehavior(Tile tile, int x, int y, GameEmoji targetEmoji) {
    if (tile.behavior != null) {
      return tile.behavior!.onSwipedWith(x, y, targetEmoji).isNotEmpty;
    }
    return false;
  }

  List<BehaviorAction> processTappedBehavior(Tile tile, int x, int y) {
    if (tile.behavior != null) {
      return tile.behavior!.onTapped(x, y);
    }
    return [];
  }

  bool hasTapBehavior(Tile tile, int x, int y) {
    if (tile.behavior != null) {
      return tile.behavior!.onTapped(x, y).isNotEmpty;
    }
    return false;
  }
}
