import 'dart:math';

import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/behaviors/models/behavior.dart';
import 'package:grimoji/features/alchemy/behaviors/clown.dart';
import 'package:grimoji/features/alchemy/behaviors/models/action_type.dart';
import 'package:grimoji/features/alchemy/behaviors/models/behavior_action.dart';
import 'package:grimoji/features/alchemy/reactions/models/reaction.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/models/tile.dart';
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

  Future<void> processTurnEndBehaviors() async {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        final tile = boardManager.gridTiles[r][c];
        if (tile.behavior != null) {
          final actions = tile.behavior!.onTurnEnd(r, c);
          executeBehaviorActions(actions, r, c);

          final boardActions = await tile.behavior!.onTurnEndWithBoard(
            r,
            c,
            boardManager.gridTiles,
            level,
          );
          executeBehaviorActions(boardActions, r, c);
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
      final x = action.x ?? centerX;
      final y = action.y ?? centerY;

      switch (action.type) {
        case ActionType.placeEmoji:
          final target = boardManager.findAdjacentEmptyTile(x, y);
          if (target != null && action.emoji != null) {
            boardManager.gridTiles[target.x][target.y].emoji = action.emoji!;
            initializeBehavior(boardManager.gridTiles[target.x][target.y]);
          }
          break;

        case ActionType.reactEmoji:
          final target = boardManager.findAdjacentFilledTile(x, y);
          if (target != null && action.emoji != null) {
            boardManager.gridTiles[target.x][target.y].emoji = action.emoji!;
            boardManager.gridTiles[target.x][target.y].clearBehavior();
          }
          break;

        case ActionType.consumeAllOfType:
          boardManager.gridTiles[x][y].isSwallowTrigger = true;
          boardManager.gridTiles[x][y].isSwallowTarget = true;

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
              if (r == x && c == y) continue;
              emojisOnBoard.add(boardManager.gridTiles[r][c].emoji);
            }
          }

          boardManager.gridTiles[x][y].isSwallowTrigger = true;
          boardManager.gridTiles[x][y].isSwallowTarget = true;

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
          bool rowAlreadyTriggered = false;
          for (int c = 0; c < BoardManager.cols; c++) {
            if (boardManager.gridTiles[x][c].isRowClearTrigger) {
              rowAlreadyTriggered = true;
              break;
            }
          }
          if (rowAlreadyTriggered) break;

          boardManager.gridTiles[x][y].isLineClearTrigger = true;
          boardManager.gridTiles[x][y].isRowClearTrigger = true;

          for (int c = 0; c < BoardManager.cols; c++) {
            if (c != y) {
              boardManager.gridTiles[x][c].isLineClearTarget = true;
            }
          }
          break;

        case ActionType.clearCol:
          bool colAlreadyTriggered = false;
          for (int r = 0; r < BoardManager.rows; r++) {
            if (boardManager.gridTiles[r][y].isColClearTrigger) {
              colAlreadyTriggered = true;
              break;
            }
          }
          if (colAlreadyTriggered) break;

          boardManager.gridTiles[x][y].isLineClearTrigger = true;
          boardManager.gridTiles[x][y].isColClearTrigger = true;

          for (int r = 0; r < BoardManager.rows; r++) {
            if (r != x) {
              boardManager.gridTiles[r][y].isLineClearTarget = true;
            }
          }
          break;

        case ActionType.wheelRoll:
          boardManager.gridTiles[x][y].isWheelTrigger = true;
          break;

        case ActionType.ghostDive:
          if (action.emoji != null) {
            boardManager.gridTiles[x][y].isGhostOrigin = true;
          } else {
            boardManager.gridTiles[x][y].isGhostTrigger = true;
          }
          break;

        case ActionType.bomb:
          boardManager.gridTiles[x][y].isTriggered = true;
          break;

        case ActionType.shuffleSurrounding:
          final centerTile = boardManager.gridTiles[x][y];
          int radius = 1;
          if (centerTile.behavior is ClownBehavior) {
            radius = (centerTile.behavior as ClownBehavior).shuffleRadius;
          }

          final List<({int x, int y, GameEmoji emoji})> surroundingTiles = [];
          for (int r = x - radius; r <= x + radius; r++) {
            for (int c = y - radius; c <= y + radius; c++) {
              if (r >= 0 &&
                  r < BoardManager.rows &&
                  c >= 0 &&
                  c < BoardManager.cols) {
                final rowDist = (r - x).abs();
                final colDist = (c - y).abs();
                if (rowDist <= radius &&
                    colDist <= radius &&
                    (r != x || c != y)) {
                  surroundingTiles.add((
                    x: r,
                    y: c,
                    emoji: boardManager.gridTiles[r][c].emoji,
                  ));
                }
              }
            }
          }

          if (surroundingTiles.isNotEmpty) {
            final shuffledEmojis = surroundingTiles
                .map((t) => t.emoji)
                .toList();
            shuffledEmojis.shuffle();

            centerTile.isClownShuffling = true;

            for (int i = 0; i < surroundingTiles.length; i++) {
              final tileCoord = surroundingTiles[i];
              boardManager.gridTiles[tileCoord.x][tileCoord.y].emoji =
                  shuffledEmojis[i];
              boardManager.gridTiles[tileCoord.x][tileCoord.y].isShuffling =
                  true;
              initializeBehavior(
                boardManager.gridTiles[tileCoord.x][tileCoord.y],
              );
            }
          }
          break;

        case ActionType.spawnPoop:
          boardManager.gridTiles[x][y].emoji = Emojis.poop;
          initializeBehavior(boardManager.gridTiles[x][y]);
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
