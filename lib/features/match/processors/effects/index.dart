import 'package:flutter/foundation.dart';

import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/board/effects/ghost_dive/effect.dart';
import 'package:grimoji/features/match/board/effects/wheel_roll/effect.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/match/detectors/threat/index.dart';
import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/models/board_region.dart';
import 'package:grimoji/features/match/models/collected_emoji.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/processors/effects/models/behavior_sweep_result.dart';
import 'package:grimoji/features/match/processors/effects/models/ghost_trigger_event.dart';
import 'package:grimoji/features/match/processors/effects/models/line_clear_event.dart';
import 'package:grimoji/features/match/processors/effects/models/pending_ghost_dive.dart';
import 'package:grimoji/features/match/processors/effects/models/pending_wheel_roll.dart';
import 'package:grimoji/features/match/processors/settlement.dart';
import 'package:grimoji/features/match/state.dart';
import 'package:grimoji/features/match/types.dart';

class EffectsProcessor {
  final GameEngine engine;
  final GameState state;
  final BoardManager boardManager;
  final SettlementProcessor settlement;

  EffectsProcessor({
    required this.engine,
    required this.state,
    required this.boardManager,
    required this.settlement,
  });

  bool get hasWheelPending => _hasTileWhere((tile) => tile.isWheelTrigger);

  bool get hasGhostPending =>
      _hasTileWhere((tile) => tile.isGhostTrigger || tile.isGhostOrigin);

  bool get hasSwallowPending =>
      _hasTileWhere((tile) => tile.isSwallowTrigger || tile.isSwallowTarget);

  void clearWheelTriggers() {
    _forEachTile((_, _, tile) => tile.isWheelTrigger = false);
  }

  List<PendingWheelRoll> prepareWheelEffects({
    required bool isHorizontal,
    required bool isWrapping,
  }) {
    const stepCount = 3;
    final plans = <PendingWheelRoll>[];

    for (int row = 0; row < BoardManager.rows; row++) {
      for (int col = 0; col < BoardManager.cols; col++) {
        final tile = engine.grid[row][col];
        if (!tile.isWheelTrigger) continue;

        tile.isWheelTrigger = false;
        final steps = <TileCoordinate>[];
        for (int i = 1; i <= stepCount; i++) {
          var stepRow = row;
          var stepCol = col;
          final offset = isWrapping ? i : -i;
          if (isHorizontal) {
            stepCol = _wrapCoordinate(stepCol, offset, BoardManager.cols);
          } else {
            stepRow = _wrapCoordinate(stepRow, offset, BoardManager.rows);
          }
          steps.add(TileCoordinate(row: stepRow, col: stepCol));
        }

        final origin = TileCoordinate(row: row, col: col);
        tile.isWheelOrigin = true;
        tile.clearBehavior();
        plans.add(
          PendingWheelRoll(
            origin: origin,
            effect: RollEffect(
              startRow: row,
              startCol: col,
              isHorizontal: isHorizontal,
              isWrapping: isWrapping,
              steps: steps,
            ),
          ),
        );
      }
    }
    return plans;
  }

  void dropWheelBombs(List<PendingWheelRoll> plans, int stepIndex) {
    for (final plan in plans) {
      final step = plan.effect.steps[stepIndex];
      engine.grid[step.row][step.col]
        ..emoji = Emojis.bomb
        ..clearBehavior();
    }
  }

  Future<bool> completeWheelEffects(List<PendingWheelRoll> plans) async {
    for (final plan in plans) {
      for (final step in plan.effect.steps) {
        engine.grid[step.row][step.col].isTriggered = true;
      }
    }
    state.updateUI();
    return await settlement.settleBoard(
          BoardRegion({for (final plan in plans) plan.origin}),
        ) !=
        null;
  }

  Future<List<PendingGhostDive>> prepareGhostEffects({
    Set<TileCoordinate> excluded = const {},
  }) async {
    final triggers = _findGhostTriggers();
    final plans = <PendingGhostDive>[];
    final reservedTargets = TileSet.from(excluded)
      ..addAll(triggers.map((trigger) => trigger.origin));

    for (final trigger in triggers) {
      final target = await ThreatDetector.findTarget(
        grid: engine.grid,
        targetEmoji: engine.level.targetEmoji,
        excluded: reservedTargets,
      );
      if (state.isDisposed) return plans;
      if (target == null) continue;

      reservedTargets.add(target);
      engine.grid[trigger.origin.row][trigger.origin.col].isGhostOrigin = true;
      if (kDebugMode) engine.grid[target.row][target.col].isGhostTarget = true;
      plans.add(
        PendingGhostDive(
          effect: GhostDiveEffect(
            origin: trigger.origin,
            target: target,
            bombOrigin: trigger.bombOrigin,
            isBomb: trigger.isBomb,
          ),
        ),
      );
    }
    return plans;
  }

  Future<List<CollectedEmoji>> completeGhostEffects(
    List<PendingGhostDive> plans,
  ) async {
    final destroyed = <TileCoordinate>{};
    final newBombs = <TileCoordinate>{};
    final collected = <CollectedEmoji>[];

    for (final plan in plans) {
      final effect = plan.effect;
      if (kDebugMode) {
        engine.grid[effect.target.row][effect.target.col].isGhostTarget = false;
      }
      if (effect.isBomb && effect.bombOrigin != null) {
        engine
                .grid[effect.bombOrigin!.row][effect.bombOrigin!.col]
                .isGhostBomb =
            false;
        destroyed.add(effect.bombOrigin!);
      }
      destroyed.add(effect.origin);
      if (effect.isBomb) {
        final targetTile = engine.grid[effect.target.row][effect.target.col];
        if (targetTile.emoji == engine.level.targetEmoji) {
          collected.add(CollectedEmoji(emoji: targetTile.emoji, count: 1));
        }
        newBombs.add(effect.target);
      } else {
        destroyed.add(effect.target);
      }
    }

    if (destroyed.isNotEmpty) boardManager.flagFlyingTargetEmojis(destroyed);
    for (final coordinate in newBombs) {
      engine.grid[coordinate.row][coordinate.col]
        ..isTriggered = true
        ..clearBehavior();
    }
    state.updateUI();

    if (destroyed.isNotEmpty) {
      await settlement.settleBoard(BoardRegion(destroyed));
    } else {
      await Future<void>.delayed(preShatterDelay);
    }
    return collected;
  }

  Future<BehaviorSweepResult> drainBehaviorFlags() async {
    final consumedTiles = <TileCoordinate>{};
    final clearedLines = <TileCoordinate>{};
    final lineClearEvents = <LineClearEvent>[];

    _forEachTile((row, col, tile) {
      if (tile.isSwallowTarget || tile.isSwallowTrigger) {
        consumedTiles.add(TileCoordinate(row: row, col: col));
        tile.isSwallowTarget = false;
        tile.isSwallowTrigger = false;
      }
      if (tile.isRowClearTrigger) {
        lineClearEvents.add(
          LineClearEvent(row: row, col: col, isHorizontal: true),
        );
      }
      if (tile.isColClearTrigger) {
        lineClearEvents.add(
          LineClearEvent(row: row, col: col, isHorizontal: false),
        );
      }
      if (tile.isLineClearTrigger || tile.isLineClearTarget) {
        clearedLines.add(TileCoordinate(row: row, col: col));
      }
    });

    if (consumedTiles.isNotEmpty &&
        await settlement.settleBoard(BoardRegion(consumedTiles)) == null) {
      return BehaviorSweepResult(
        consumedTiles: consumedTiles,
        clearedLines: clearedLines,
        lineClearEvents: lineClearEvents,
        hasBoardChanged: false,
      );
    }

    return BehaviorSweepResult(
      consumedTiles: consumedTiles,
      clearedLines: clearedLines,
      lineClearEvents: lineClearEvents,
      hasBoardChanged: consumedTiles.isNotEmpty || clearedLines.isNotEmpty,
    );
  }

  Future<bool> completeLineClear(TileSet destroyed) async {
    for (final coordinate in destroyed) {
      engine.grid[coordinate.row][coordinate.col]
        ..isLineClearTrigger = false
        ..isLineClearTarget = false
        ..isRowClearTrigger = false
        ..isColClearTrigger = false
        ..isBloodTarget = false;
    }
    return await settlement.settleBoard(BoardRegion(destroyed)) != null;
  }

  List<GhostTriggerEvent> _findGhostTriggers() {
    final triggers = <GhostTriggerEvent>[];
    _forEachTile((row, col, tile) {
      if (!tile.isGhostTrigger && !tile.isGhostOrigin) return;
      TileCoordinate? bombOrigin;
      if (tile.isGhostOrigin) {
        for (final adjacent in boardManager.getAdjacentTiles(row, col)) {
          if (adjacent.emoji == Emojis.bomb) {
            bombOrigin = adjacent.coordinate;
            adjacent.isGhostBomb = true;
            break;
          }
        }
      }
      triggers.add(
        GhostTriggerEvent(
          origin: TileCoordinate(row: row, col: col),
          isBomb: tile.isGhostOrigin,
          bombOrigin: bombOrigin,
        ),
      );
      tile.isGhostTrigger = false;
      tile.isGhostOrigin = false;
      tile.clearBehavior();
    });
    return triggers;
  }

  int _wrapCoordinate(int current, int offset, int maxIndex) =>
      ((current + offset) % maxIndex + maxIndex) % maxIndex;

  bool _hasTileWhere(bool Function(Tile tile) predicate) {
    for (final row in engine.grid) {
      for (final tile in row) {
        if (predicate(tile)) return true;
      }
    }
    return false;
  }

  void _forEachTile(void Function(int row, int col, Tile tile) action) {
    for (int row = 0; row < BoardManager.rows; row++) {
      for (int col = 0; col < BoardManager.cols; col++) {
        action(row, col, engine.grid[row][col]);
      }
    }
  }
}
