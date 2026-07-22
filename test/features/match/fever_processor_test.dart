import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/controllers/hint.dart';
import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/processors/effects/index.dart';
import 'package:grimoji/features/match/processors/fever/index.dart';
import 'package:grimoji/features/match/processors/settlement.dart';
import 'package:grimoji/features/match/state.dart';
import '../../helpers/test_level.dart';
import '../../mocks/audio_controller.dart';

void main() {
  group('FeverProcessor', () {
    late GameState state;
    late FeverProcessor fever;

    setUp(() {
      final level = TestLevel.create();
      final boardManager = BoardManager(level);
      boardManager.initialize();
      final engine = GameEngine(
        level: level,
        boardManager: boardManager,
        playSfx: (_) {},
      );
      engine.initialize();
      state = GameState();
      final effects = EffectsProcessor(
        engine: engine,
        state: state,
        boardManager: boardManager,
        settlement: SettlementProcessor(
          engine: engine,
          state: state,
          boardManager: boardManager,
        ),
      );
      fever = FeverProcessor(
        engine: engine,
        state: state,
        boardManager: boardManager,
        effects: effects,
        hint: HintController(
          engine: engine,
          state: state,
          audio: MockAudioController(),
        ),
        cascadeSequence: (_) async {},
        processEffects: ({required isHorizontal, required isWrapping}) async =>
            true,
        dispatchGhostEffects: (_, {required simultaneous}) async => true,
        sweepBehaviors: () async => false,
      );
    });

    test('completes fever mode and exits fever state', () async {
      final completed = await fever.executeSequence(
        bonusBombs: 0,
        onSpawn: () {},
      );

      expect(completed, isTrue);
      expect(state.isFeverComplete, isTrue);
      expect(state.isFeverTime, isFalse);
    });

    test('returns false without completing fever when disposed', () async {
      state.dispose();

      final completed = await fever.executeSequence(
        bonusBombs: 0,
        onSpawn: () {},
      );

      expect(completed, isFalse);
      expect(state.isFeverComplete, isFalse);
      expect(state.isFeverTime, isFalse);
    });

    test(
      'skipping an active fever exits through the shared cleanup path',
      () async {
        state.setProcessing(true);
        final sequence = fever.executeSequence(bonusBombs: 0, onSpawn: () {});

        fever.skip();

        expect(await sequence, isFalse);
        expect(state.isFeverComplete, isFalse);
        expect(state.isFeverTime, isFalse);
      },
    );
  });
}
