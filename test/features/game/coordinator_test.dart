import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/game/board/models/coordinate.dart';
import 'package:grimoji/utils/test_helpers.dart';

void main() {
  group('GameCoordinator tests', () {
    late GameLevel level;
    late LevelState levelState;

    setUp(() {
      level = const GameLevel(
        number: 1,
        availableEmojis: [Emojis.fire, Emojis.rock, Emojis.droplet, Emojis.alien],
        targetEmoji: Emojis.fire,
        targetAmount: 10,
        timeLimit: 60,
        goal: 'Test goal',
        description: 'Test description',
      );
    });

    test('Should initialize and start initial drop', () {
      fakeAsync((async) {
        levelState = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
        );

        levelState.startLevel();
        async.elapse(gravityAnimationTime);

        expect(levelState.engine.grid[0][0].coordinate.row, 0);
      });
    });

    test('Should resolve swipe and process valid match', () {
      fakeAsync((async) {
        levelState = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
        );

        TestHelpers.genDeadLockGrid(levelState.engine);
        levelState.startLevel();
        async.elapse(gravityAnimationTime);

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

        expect(levelState.gameState.isProcessing, isFalse);
      });
    });

    test('Should reset hint timer correctly', () {
      fakeAsync((async) {
        levelState = LevelState(
          level: level,
          onWin: (_) {},
          onLose: () {},
        );

        levelState.startLevel();
        async.elapse(gravityAnimationTime);

        async.elapse(const Duration(seconds: 5));
        
        bool hasHint = levelState.engine.grid.any(
          (row) => row.any((tile) => tile.isHinting)
        );
        expect(hasHint, isTrue, reason: 'Hints should appear after 5s idle');

        levelState.coordinator.resetHintTimer();
        
        hasHint = levelState.engine.grid.any(
          (row) => row.any((tile) => tile.isHinting)
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
        );

        TestHelpers.genDeadLockGrid(levelState.engine);
        levelState.startLevel();
        async.elapse(gravityAnimationTime);

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
        );

        levelState.startLevel();
        async.elapse(gravityAnimationTime);

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
        );

        levelState.startLevel();
        async.elapse(gravityAnimationTime);

        levelState.engine.grid[0][0].isHinting = true;
        levelState.engine.grid[0][1].isHinting = true;

        levelState.coordinator.resetHintTimer();

        expect(levelState.engine.grid[0][0].isHinting, isFalse);
        expect(levelState.engine.grid[0][1].isHinting, isFalse);
      });
    });
  });
}