import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/processors/effects/index.dart';
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
  });
}
