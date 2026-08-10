import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/levels/difficulty.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/level/managers/crimson.dart';
import 'package:grimoji/features/level/managers/goal.dart';
import '../../helpers/test_level.dart';

void main() {
  group('CrimsonFever', () {
    late GameLevel level;
    late GoalManager goalManager;
    late CrimsonFever crimson;

    setUp(() {
      level = TestLevel.create(number: 1, targetAmount: 5);
      goalManager = GoalManager(targetAmount: 5);
      goalManager.add(5); 
      crimson = CrimsonFever(level: level, goalManager: goalManager);
    });

    test('uses LevelDifficulty.crimsonStarTargetFor as target', () {
      final expected = LevelDifficulty.crimsonStarTargetFor(level);
      expect(crimson.target, expected);
    });

    test('awards 0 stars when score is below threshold1', () {
      final target = crimson.target;
      crimson.addScore((target * level.crimsonThreshold1 - 1).floor());
      expect(crimson.stars, 0);
    });

    test('awards 1 star at threshold1', () {
      final target = crimson.target;
      crimson.addScore((target * level.crimsonThreshold1).ceil());
      expect(crimson.stars, 1);
    });

    test('awards 2 stars at threshold2', () {
      final target = crimson.target;
      crimson.addScore((target * level.crimsonThreshold2).ceil());
      expect(crimson.stars, 2);
    });

    test('awards 3 stars at threshold3', () {
      final target = crimson.target;
      crimson.addScore((target * level.crimsonThreshold3).ceil());
      expect(crimson.stars, 3);
      expect(crimson.hasMaxStars, isTrue);
    });

    test('hasMaxStars is false below 3 stars', () {
      final target = crimson.target;
      crimson.addScore((target * level.crimsonThreshold2).ceil());
      expect(crimson.hasMaxStars, isFalse);
    });

    test('does not add score when goal is incomplete', () {
      final incompleteGoal = GoalManager(targetAmount: 10);
      final tracker = CrimsonFever(level: level, goalManager: incompleteGoal);
      tracker.addScore(1000);
      expect(tracker.score, 0);
    });

    test('respects custom thresholds from GameLevel', () {
      final customLevel = GameLevel(
        number: 5,
        targetAmount: 10,
        timeLimit: 200,
        targetEmoji: level.targetEmoji,
        availableEmojis: level.availableEmojis,
        crimsonThreshold1: 0.2,
        crimsonThreshold2: 0.5,
        crimsonThreshold3: 0.8,
      );
      final goal = GoalManager(targetAmount: 10);
      goal.add(10);
      final tracker = CrimsonFever(level: customLevel, goalManager: goal);
      final target = tracker.target;

      tracker.addScore((target * 0.2).ceil());
      expect(tracker.stars, 1);
    });

    test('scaled target increases with level number', () {
      final earlyLevel = TestLevel.create(number: 1, targetAmount: 5);
      final lateLevel = TestLevel.create(number: 80, targetAmount: 5);
      final earlyTarget = LevelDifficulty.crimsonStarTargetFor(earlyLevel);
      final lateTarget = LevelDifficulty.crimsonStarTargetFor(lateLevel);
      expect(lateTarget, greaterThan(earlyTarget));
    });
  });
}
