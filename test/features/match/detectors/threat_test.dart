import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/detectors/threat/index.dart';
import '../../../helpers/test_grid.dart';

void main() {
  group('ThreatDetector Tests', () {
    late BoardManager boardManager;
    late GameLevel level;
    late TestGrid testGrid;

    setUp(() {
      RecipeBook.initialize();

      level = GameLevel(
        number: 1,
        timeLimit: 60,
        targetEmoji: Emojis.bomb,
        targetAmount: 5,
        availableEmojis: [
          Emojis.fire,
          Emojis.rock,
          Emojis.droplet,
          Emojis.alien,
        ],
        goal: 'Test goal',
        description: 'Test description',
      );

      boardManager = BoardManager(level);
      boardManager.initialize();
      testGrid = TestGrid(boardManager);
    });

    test(
      'Should target a tile whose destruction creates an exact target match',
      () async {
        testGrid.fillPattern([
          Emojis.rock,
          Emojis.droplet,
          Emojis.alien,
          Emojis.spider,
          Emojis.mushroom,
          Emojis.worm,
          Emojis.bug,
          Emojis.ocean,
        ]);
        testGrid.place(1, 2, Emojis.fire);
        testGrid.place(2, 2, Emojis.fire);
        testGrid.place(4, 2, Emojis.fire);
        testGrid.place(5, 2, Emojis.fire);

        final target = await ThreatDetector.findTarget(
          grid: boardManager.gridTiles,
          targetEmoji: level.targetEmoji,
        );

        expect(target, isNotNull);
        expect(target!.row, equals(3));
        expect(target.col, equals(2));
      },
    );

    test(
      'Should prioritize a target-path match over a non-target match',
      () async {
        testGrid.fillPattern([
          Emojis.rock,
          Emojis.droplet,
          Emojis.alien,
          Emojis.spider,
          Emojis.mushroom,
          Emojis.worm,
          Emojis.bug,
          Emojis.ocean,
        ]);
        testGrid.place(1, 0, Emojis.leaflessTree);
        testGrid.place(2, 0, Emojis.leaflessTree);
        testGrid.place(4, 0, Emojis.leaflessTree);
        testGrid.place(1, 2, Emojis.rock);
        testGrid.place(2, 2, Emojis.rock);
        testGrid.place(4, 2, Emojis.rock);

        final target = await ThreatDetector.findTarget(
          grid: boardManager.gridTiles,
          targetEmoji: level.targetEmoji,
        );

        expect(target, isNotNull);
        expect(target!.row, equals(3));
        expect(target.col, equals(0));
      },
    );
  });
}
