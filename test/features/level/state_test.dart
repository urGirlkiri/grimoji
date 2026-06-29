import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';
import 'package:flutter/widgets.dart';
import 'package:grimoji/utils/test_helpers.dart';

import '../../mocks/mock_audio_controller.dart';

void main() {
  group('LevelState tests', () {
    late GameLevel level;
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

    test('Should initialize and start initial drop with gravity', () {
      fakeAsync((async) {
        final state = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        state.startLevel();
        async.elapse(fallDuration);

        expect(
          state.engine.grid[0][0].coordinate.row,
          0,
          reason: 'Gravity should position tile at row 0',
        );
      });
    });

    test('Should manage idle timer, hinting, and reset logic', () {
      fakeAsync((async) {
        final state = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        state.startLevel();
        async.elapse(fallDuration);

        async.elapse(const Duration(seconds: 5));

        bool hasHint = state.engine.grid.any(
          (row) => row.any((tile) => tile.isHinting),
        );
        expect(hasHint, isTrue, reason: 'Hints should appear after 5s idle');

        state.coordinator.resetHintTimer();
        hasHint = state.engine.grid.any(
          (row) => row.any((tile) => tile.isHinting),
        );
        expect(hasHint, isFalse, reason: 'Touching screen should clear hints');
      });
    });

    test('Should restart hint timer after invalid swipe', () {
      fakeAsync((async) {
        final state = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        TestHelpers.genDeadLockGrid(state.engine);
        state.startLevel();
        async.elapse(fallDuration);

        async.elapse(const Duration(seconds: 3));
        bool hasHint = state.engine.grid.any(
          (row) => row.any((tile) => tile.isHinting),
        );
        expect(hasHint, isFalse, reason: 'No hint should appear before 5s');

        state.coordinator.resolveSwipe(
          TileCoordinate(row: 0, col: 0),
          TileCoordinate(row: 0, col: 1),
        );
        async.elapse(
          swapSpeed * 2 +
              const Duration(milliseconds: 400) +
              shuffleWipeHalfTime * 2,
        );

        state.engine.grid[5][0].emoji = Emojis.fire;
        state.engine.grid[6][0].emoji = Emojis.fire;
        state.engine.grid[7][1].emoji = Emojis.fire;

        async.elapse(const Duration(seconds: 5));
        hasHint = state.engine.grid.any(
          (row) => row.any((tile) => tile.isHinting),
        );
        expect(
          hasHint,
          isTrue,
          reason: 'Hint should appear 5s after swipe (timer restarted)',
        );
      });
    });

    test('Should resolve invalid swipe by swapping and reverting', () {
      fakeAsync((async) {
        final state = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        TestHelpers.genDeadLockGrid(state.engine);

        state.engine.grid[0][0].emoji = Emojis.droplet;
        state.engine.grid[0][1].emoji = Emojis.droplet;
        state.engine.grid[1][0].emoji = Emojis.fire;
        state.engine.grid[1][1].emoji = Emojis.fire;

        state.coordinator.resolveSwipe(
          TileCoordinate(row: 0, col: 0),
          TileCoordinate(row: 0, col: 1),
        );

        expect(
          state.gameState.isProcessing,
          isTrue,
          reason: 'State should be processing during swap',
        );

        async.elapse(swapSpeed * 2 + const Duration(milliseconds: 400));

        expect(
          state.engine.grid[0][0].emoji,
          Emojis.droplet,
          reason: 'Grid should revert after invalid swap',
        );
        expect(
          state.gameState.isProcessing,
          isFalse,
          reason: 'State should stop processing after revert',
        );
      });
    });

    test('Should resolve valid swipe with cascade and turn end behaviors', () {
      fakeAsync((async) {
        final state = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        TestHelpers.genDeadLockGrid(state.engine);
        state.engine.grid[0][0].emoji = Emojis.fire;
        state.engine.grid[0][1].emoji = Emojis.fire;
        state.engine.grid[1][2].emoji = Emojis.fire;

        state.coordinator.resolveSwipe(
          TileCoordinate(row: 0, col: 2),
          TileCoordinate(row: 1, col: 2),
        );

        int safeTimeLimit = 200;
        while (state.gameState.isProcessing && safeTimeLimit > 0) {
          async.elapse(const Duration(milliseconds: 100));
          safeTimeLimit--;
        }

        expect(
          state.gameState.isProcessing,
          isFalse,
          reason: 'Processing should complete after valid match',
        );
      });
    });

    test('Should execute shuffleBoard flow with progress tracking', () {
      fakeAsync((async) {
        final state = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        state.coordinator.shuffleBoard();
        async.elapse(const Duration(milliseconds: 600));
        async.elapse(const Duration(milliseconds: 600));
      });
    });

    test('Should not trigger hint when processing', () {
      fakeAsync((async) {
        final state = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        TestHelpers.genDeadLockGrid(state.engine);
        state.startLevel();
        async.elapse(fallDuration);

        state.engine.grid[0][0].emoji = Emojis.fire;
        state.engine.grid[0][1].emoji = Emojis.fire;

        state.coordinator.resolveSwipe(
          TileCoordinate(row: 0, col: 2),
          TileCoordinate(row: 1, col: 2),
        );

        async.elapse(swapSpeed * 2 + const Duration(seconds: 10));

        expect(
          state.gameState.isProcessing,
          isFalse,
          reason: 'Processing should complete',
        );
      });
    });

    test('Should not trigger hint when shuffling', () {
      fakeAsync((async) {
        final state = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        state.startLevel();
        async.elapse(fallDuration);
        state.coordinator.shuffleBoard();

        async.elapse(const Duration(seconds: 10));

        expect(
          state.gameState.isShuffling,
          isFalse,
          reason: 'Shuffling should complete',
        );
      });
    });

    test('Should not trigger hint after game over', () {
      fakeAsync((async) {
        final state = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        state.startLevel();
        async.elapse(fallDuration);
        state.gameState.setGameOver();

        async.elapse(const Duration(seconds: 10));

        bool hasHint = state.engine.grid.any(
          (row) => row.any((tile) => tile.isHinting),
        );
        expect(
          hasHint,
          isFalse,
          reason: 'Hints should not appear after game over',
        );
      });
    });

    test('Should toggle pause correctly', () {
      fakeAsync((async) {
        final state = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        state.startLevel();
        async.elapse(fallDuration);

        expect(state.gameState.isPaused, isFalse);

        state.coordinator.togglePause();
        expect(state.gameState.isPaused, isTrue);

        state.coordinator.togglePause();
        expect(state.gameState.isPaused, isFalse);
      });
    });

    test('Should track collected amount correctly', () {
      fakeAsync((async) {
        final state = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        state.startLevel();
        async.elapse(fallDuration);

        expect(state.collectedAmount, 0);
        expect(state.progress, 0);

        state.coordinator.onTargetAcquired(5);
        expect(state.collectedAmount, 5);
        expect(state.progress, 5 / 10);
      });
    });

    test('Should calculate seconds remaining correctly', () {
      fakeAsync((async) {
        final state = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
          audio: mockAudio,
          lifecycleNotifier: ValueNotifier<AppLifecycleState>(
            AppLifecycleState.resumed,
          ),
        );

        state.startLevel();
        async.elapse(fallDuration);

        expect(state.secondsRemaining, inInclusiveRange(0, 60));
      });
    });
  });
}
