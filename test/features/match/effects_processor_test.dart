import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/clear.dart';
import 'package:grimoji/features/alchemy/behaviors/dive.dart';
import 'package:grimoji/features/match/board/effects/ghost_dive/effect.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/processors/effects/index.dart';
import 'package:grimoji/features/match/processors/effects/models/ghost_trigger_event.dart';
import 'package:grimoji/features/match/processors/effects/models/pending_ghost_dive.dart';
import 'package:grimoji/features/match/processors/settlement.dart';
import 'package:grimoji/features/match/state.dart';
import '../../helpers/test_level.dart';

void main() {
  group('EffectsProcessor', () {
    late GameEngine engine;
    late EffectsProcessor effects;

    setUp(() {
      final level = TestLevel.create(targetEmoji: Emojis.fire);
      final boardManager = BoardManager(level);
      boardManager.initialize();
      engine = GameEngine(
        level: level,
        boardManager: boardManager,
        playSfx: (_) {},
      );
      engine.initialize();
      final state = GameState();
      effects = EffectsProcessor(
        engine: engine,
        state: state,
        boardManager: boardManager,
        settlement: SettlementProcessor(
          engine: engine,
          state: state,
          boardManager: boardManager,
        ),
      );
    });

    test('prepares wheel roll payload and consumes the trigger', () {
      final tile = engine.grid[3][2]..isWheelTrigger = true;

      final plans = effects.prepareWheelEffects(
        isHorizontal: true,
        isWrapping: true,
      );

      expect(plans, hasLength(1));
      expect(plans.single.effect.startRow, 3);
      expect(plans.single.effect.startCol, 2);
      expect(plans.single.effect.steps.map((coordinate) => coordinate.col), [
        3,
        4,
        0,
      ]);
      expect(tile.isWheelTrigger, isFalse);
      expect(tile.isWheelOrigin, isTrue);
    });

    test('drains swallow flags without coupling to player feedback', () async {
      final tile = engine.grid[2][2]
        ..isSwallowTrigger = true
        ..isSwallowTarget = true;

      final result = await effects.drainBehaviorFlags();

      expect(result.hasBoardChanged, isTrue);
      expect(result.consumedTiles, hasLength(1));
      expect(tile.isSwallowTrigger, isFalse);
      expect(tile.isSwallowTarget, isFalse);
    });

    test(
      'prepares pole-carrying ghost dive with correct orientation',
      () async {
        _fillGrid(engine, Emojis.rock);
        engine.grid[0][1].emoji = Emojis.ghost;
        engine.grid[0][1].behavior = DiveBehavior();
        engine.grid[0][1].isGhostOrigin = true;

        engine.grid[0][0].emoji = Emojis.barberPole;
        engine.grid[0][0].behavior = ClearBehavior(isHorizontal: true);

        engine.grid[2][2].emoji = Emojis.fire;
        _syncTileCoordinates(engine);

        final plans = await effects.prepareGhostEffects();

        expect(plans, hasLength(1));
        final effect = plans.single.effect;
        expect(effect.powerup, GhostPowerup.pole);
        expect(effect.powerupOrigin?.row, 0);
        expect(effect.powerupOrigin?.col, 0);
        expect(effect.isHorizontal, isTrue);
      },
    );

    test(
      'completes pole-carrying ghost dive and triggers line clear at target',
      () async {
        _fillGrid(engine, Emojis.rock);
        _syncTileCoordinates(engine);

        final origin = TileCoordinate(row: 0, col: 1);
        final powerupOrigin = TileCoordinate(row: 0, col: 0);
        final target = TileCoordinate(row: 3, col: 2);

        final effect = GhostDiveEffect(
          origin: origin,
          target: target,
          powerupOrigin: powerupOrigin,
          powerup: GhostPowerup.pole,
          isHorizontal: false,
        );

        await effects.completeGhostEffects([PendingGhostDive(effect: effect)]);

        expect(engine.grid[origin.row][origin.col].isGhostOrigin, isFalse);
        expect(
          engine.grid[powerupOrigin.row][powerupOrigin.col].isGhostPowerup,
          isFalse,
        );

        expect(engine.grid[target.row][target.col].isColClearTrigger, isTrue);
        expect(engine.grid[target.row][target.col].isLineClearTrigger, isTrue);
        for (int r = 0; r < BoardManager.rows; r++) {
          if (r == target.row) continue;
          expect(engine.grid[r][target.col].isLineClearTarget, isTrue);
        }
      },
    );
  });
}

void _syncTileCoordinates(GameEngine engine) {
  for (int r = 0; r < BoardManager.rows; r++) {
    for (int c = 0; c < BoardManager.cols; c++) {
      engine.grid[r][c].coordinate = TileCoordinate(row: r, col: c);
    }
  }
}

void _fillGrid(GameEngine engine, GameEmoji emoji) {
  for (int r = 0; r < BoardManager.rows; r++) {
    for (int c = 0; c < BoardManager.cols; c++) {
      engine.grid[r][c].emoji = emoji;
    }
  }
}
