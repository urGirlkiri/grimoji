import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/behaviors/clear.dart';
import 'package:grimoji/features/alchemy/behaviors/wheel.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:flutter/widgets.dart';
import 'package:grimoji/features/match/board/manager.dart';
import '../../mocks/mock_audio_controller.dart';
import '../../helpers/index.dart';

void main() {
  group('GameCoordinator tests', () {
    late GameLevel level;
    late LevelState levelState;
    late MockAudioController mockAudio;

    setUp(() {
      level = GameLevel(
        number: 1,
        availableEmojis: [
          Emojis.fire,
          Emojis.rock,
          Emojis.droplet,
          Emojis.alien,
        ],
        targetEmoji: Emojis.fire,
        targetAmount: 10,
        timeLimit: 60,
        goal: 'Test goal',
        description: 'Test description',
      );
      mockAudio = MockAudioController();
    });

    test('Should initialize and start initial drop', () {
      fakeAsync((async) {
        levelState = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        levelState.startLevel();
        async.elapse(fallDuration);

        expect(levelState.engine.grid[0][0].coordinate.row, 0);
      });
    });

    test('Should resolve swipe and process valid match', () {
      fakeAsync((async) {
        levelState = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        TestHelpers.genDeadLockGrid(levelState.engine);
        levelState.startLevel();
        async.elapse(fallDuration);

        levelState.engine.grid[0][0].emoji = Emojis.fire;
        levelState.engine.grid[0][1].emoji = Emojis.fire;
        levelState.engine.grid[1][0].emoji = Emojis.fire;

        levelState.coordinator.resolveSwipe(
          TileCoordinate(row: 0, col: 0),
          TileCoordinate(row: 1, col: 0),
        );

        int safeTimeLimit = 200;
        while (levelState.gameState.isProcessing && safeTimeLimit > 0) {
          async.elapse(const Duration(milliseconds: 100));
          safeTimeLimit--;
        }

        async.elapse(const Duration(seconds: 3));

        expect(levelState.gameState.isProcessing, isFalse);
      });
    });

    test('Should reset hint timer correctly', () {
      fakeAsync((async) {
        levelState = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        levelState.startLevel();
        async.elapse(fallDuration);

        levelState.engine.grid[0][0].isHinting = true;
        levelState.engine.grid[0][1].isHinting = true;
        levelState.engine.grid[0][0].hintPartner =
            levelState.engine.grid[0][1].coordinate;
        levelState.engine.grid[0][1].hintPartner =
            levelState.engine.grid[0][0].coordinate;

        bool hasHint = levelState.engine.grid.any(
          (row) => row.any((tile) => tile.isHinting),
        );
        expect(hasHint, isTrue, reason: 'Hints should be set');

        levelState.coordinator.resetHintTimer();

        hasHint = levelState.engine.grid.any(
          (row) => row.any((tile) => tile.isHinting),
        );
        expect(hasHint, isFalse, reason: 'Hints should be cleared after reset');
      });
    });

    test('Should shuffle board when no moves available', () {
      fakeAsync((async) {
        levelState = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        TestHelpers.genDeadLockGrid(levelState.engine);
        levelState.startLevel();
        async.elapse(fallDuration);

        levelState.coordinator.shuffleBoard();

        async.elapse(const Duration(milliseconds: 600));
        async.elapse(const Duration(milliseconds: 600));

        expect(levelState.gameState.isShuffling, isFalse);
      });
    });

    test('Should toggle pause correctly', () {
      fakeAsync((async) {
        levelState = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        levelState.startLevel();
        async.elapse(fallDuration);

        expect(levelState.gameState.isPaused, isFalse);

        levelState.coordinator.togglePause();
        expect(levelState.gameState.isPaused, isTrue);

        levelState.coordinator.togglePause();
        expect(levelState.gameState.isPaused, isFalse);
      });
    });

    test('Should clear hints when resetHintTimer is called', () {
      fakeAsync((async) {
        levelState = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        levelState.startLevel();
        async.elapse(fallDuration);

        levelState.engine.grid[0][0].isHinting = true;
        levelState.engine.grid[0][1].isHinting = true;

        levelState.coordinator.resetHintTimer();

        expect(levelState.engine.grid[0][0].isHinting, isFalse);
        expect(levelState.engine.grid[0][1].isHinting, isFalse);
      });
    });

    test('Black hole should auto trigger during fever', () {
      fakeAsync((async) {
        levelState = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        levelState.startLevel();
        async.elapse(fallDuration);

        TestHelpers.genDeadLockGrid(levelState.engine);
        levelState.engine.initializeBehaviors();

        levelState.engine.grid[0][0].emoji = Emojis.hole;
        levelState.engine.grid[0][1].emoji = Emojis.fire;
        levelState.engine.grid[1][0].emoji = Emojis.fire;
        levelState.engine.grid[0][2].emoji = Emojis.bomb;

        unawaited(levelState.coordinator.executeFeverSequence(0, () {}));
        async.elapse(const Duration(seconds: 2));

        expect(levelState.engine.grid[0][0].emoji, isNot(Emojis.hole));
        expect(
          levelState.engine.grid.any(
            (row) => row.any((tile) => tile.emoji == Emojis.bomb),
          ),
          isTrue,
        );
        expect(levelState.gameState.isGameOver, isTrue);
      });
    });

    test('Barber pole should auto trigger during fever', () {
      fakeAsync((async) {
        levelState = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        levelState.startLevel();
        async.elapse(fallDuration);

        TestHelpers.genDeadLockGrid(levelState.engine);
        levelState.engine.initializeBehaviors();

        levelState.engine.grid[0][0].emoji = Emojis.barberPole;
        levelState.engine.grid[0][0].behavior = ClearBehavior(
          isHorizontal: true,
        );

        unawaited(levelState.coordinator.executeFeverSequence(0, () {}));
        async.elapse(const Duration(seconds: 2));

        expect(levelState.engine.grid[0][0].emoji, isNot(Emojis.barberPole));
        expect(levelState.gameState.isGameOver, isTrue);
      });
    });

    test('Wheel should auto trigger during fever', () {
      fakeAsync((async) {
        levelState = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        levelState.startLevel();
        async.elapse(fallDuration);

        TestHelpers.genDeadLockGrid(levelState.engine);
        levelState.engine.initializeBehaviors();

        levelState.engine.grid[3][2].emoji = Emojis.wheel;
        levelState.engine.grid[3][2].behavior = WheelBehavior();

        unawaited(levelState.coordinator.executeFeverSequence(0, () {}));
        async.elapse(const Duration(seconds: 5));

        final bombCount = levelState.engine.grid
            .expand((row) => row)
            .where((tile) => tile.emoji == Emojis.bomb)
            .length;
        expect(bombCount, greaterThan(0));
        expect(levelState.engine.grid[3][2].emoji, isNot(Emojis.wheel));
        expect(levelState.gameState.isGameOver, isTrue);
      });
    });

    test(
      'Ghosts should auto trigger during fever with simultaneous dive animations',
      () async {
        final ghostLevel = GameLevel(
          number: 1,
          availableEmojis: [Emojis.rock, Emojis.droplet, Emojis.alien],
          targetEmoji: Emojis.fire,
          targetAmount: 10,
          timeLimit: 60,
          goal: 'Test goal',
          description: 'Test description',
        );

        levelState = LevelState(
          level: ghostLevel,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        levelState.startLevel();

        for (int r = 0; r < BoardManager.rows; r++) {
          for (int c = 0; c < BoardManager.cols; c++) {
            levelState.engine.grid[r][c].emoji = Emojis.rock;
          }
        }

        levelState.engine.grid[0][0].emoji = Emojis.ghost;
        levelState.engine.grid[1][1].emoji = Emojis.ghost;
        levelState.engine.grid[7][0].emoji = Emojis.fire;

        levelState.engine.initializeBehaviors();

        await levelState.coordinator.executeFeverSequence(0, () {});

        final fireCount = levelState.engine.grid
            .expand((row) => row)
            .where((tile) => tile.emoji == Emojis.fire)
            .length;
        final ghostCount = levelState.engine.grid
            .expand((row) => row)
            .where((tile) => tile.emoji == Emojis.ghost)
            .length;

        expect(ghostCount, 0);
        expect(fireCount, 0);
        expect(levelState.gameState.isGameOver, isTrue);
      },
    );
  });
}
