import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/detectors/hint/index.dart';
import '../../../helpers/test_grid.dart';

void main() {
  group('HintDetector Tests', () {
    late BoardManager boardManager;
    late List<List<Tile>> grid;
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
      grid = boardManager.gridTiles;
      testGrid = TestGrid(boardManager);
    });

    group('No moves', () {
      test('Should return null when no valid swipe produces a match', () async {
        testGrid.fillPattern([
          Emojis.fire,
          Emojis.rock,
          Emojis.droplet,
          Emojis.alien,
        ]);

        final hint = await HintDetector.findBestMove(
          grid: grid,
          targetEmoji: level.targetEmoji,
        );

        expect(hint, isNull);
      });
    });

    group('Basic match detection', () {
      test('Should return two coordinates when a match exists', () async {
        testGrid.fillPattern([
          Emojis.fire,
          Emojis.rock,
          Emojis.droplet,
          Emojis.alien,
        ]);
        testGrid.place(0, 0, Emojis.fire);
        testGrid.place(0, 1, Emojis.fire);
        testGrid.place(0, 2, Emojis.fire);

        final hint = await HintDetector.findBestMove(
          grid: grid,
          targetEmoji: level.targetEmoji,
        );

        expect(hint, isNotNull);
        expect(hint!.length, 3);
      });

      test('Should return valid board coordinates', () async {
        testGrid.fillPattern([
          Emojis.fire,
          Emojis.rock,
          Emojis.droplet,
          Emojis.alien,
        ]);
        testGrid.place(0, 0, Emojis.fire);
        testGrid.place(0, 1, Emojis.fire);
        testGrid.place(0, 2, Emojis.fire);

        final hint = await HintDetector.findBestMove(
          grid: grid,
          targetEmoji: level.targetEmoji,
        );

        expect(hint![0].row, inInclusiveRange(0, BoardManager.rows - 1));
        expect(hint[0].col, inInclusiveRange(0, BoardManager.cols - 1));
        expect(hint[1].row, inInclusiveRange(0, BoardManager.rows - 1));
        expect(hint[1].col, inInclusiveRange(0, BoardManager.cols - 1));
      });

      test(
        'Should return adjacent tiles (differ by exactly 1 in row or col)',
        () async {
          testGrid.fillPattern([
            Emojis.fire,
            Emojis.rock,
            Emojis.droplet,
            Emojis.alien,
          ]);
          grid[0][0].emoji = Emojis.fire;
          grid[0][1].emoji = Emojis.fire;
          grid[0][2].emoji = Emojis.fire;

          final hint = await HintDetector.findBestMove(
            grid: grid,
            targetEmoji: level.targetEmoji,
          );

          final TileCoordinate a = hint![0];
          final TileCoordinate b = hint[1];
          final rowDiff = (a.row - b.row).abs();
          final colDiff = (a.col - b.col).abs();
          expect(rowDiff + colDiff, 1);
        },
      );
    });

    group('Completing tile accuracy', () {
      test(
        'Should identify completing tile at right end of horizontal match',
        () async {
          final fireLevel = GameLevel(
            number: 1,
            timeLimit: 60,
            targetEmoji: Emojis.fire,
            targetAmount: 10,
            availableEmojis: [Emojis.fire, Emojis.rock],
            goal: 'test',
            description: 'test',
          );

          testGrid.fillPattern([
            Emojis.droplet,
            Emojis.spider,
            Emojis.bone,
            Emojis.worm,
          ]);
          testGrid.place(0, 0, Emojis.fire);
          testGrid.place(0, 1, Emojis.fire);
          testGrid.place(0, 2, Emojis.rock);
          testGrid.place(0, 3, Emojis.fire);

          final hint = await HintDetector.findBestMove(
            grid: grid,
            targetEmoji: fireLevel.targetEmoji,
          );

          expect(hint, isNotNull);
          expect(hint!.length, 3);
          expect(
            hint[2].row,
            equals(0),
            reason: "Completing tile row should be 0",
          );
          expect(
            hint[2].col,
            equals(3),
            reason: "Completing tile col should be 3",
          );
        },
      );

      test(
        'Should identify completing tile at left end of horizontal match',
        () async {
          final fireLevel = GameLevel(
            number: 1,
            timeLimit: 60,
            targetEmoji: Emojis.fire,
            targetAmount: 10,
            availableEmojis: [Emojis.fire, Emojis.rock],
            goal: 'test',
            description: 'test',
          );

          testGrid.fillPattern([
            Emojis.droplet,
            Emojis.spider,
            Emojis.bone,
            Emojis.worm,
          ]);
          testGrid.place(0, 0, Emojis.fire);
          testGrid.place(0, 1, Emojis.rock);
          testGrid.place(0, 2, Emojis.fire);
          testGrid.place(0, 3, Emojis.fire);

          final hint = await HintDetector.findBestMove(
            grid: grid,
            targetEmoji: fireLevel.targetEmoji,
          );

          expect(hint, isNotNull);
          expect(
            hint![2].row,
            equals(0),
            reason: "Completing tile row should be 0",
          );
          expect(
            hint[2].col,
            equals(0),
            reason: "Completing tile col should be 0 (the Fire moving in)",
          );
        },
      );

      test(
        'Should identify completing tile at bottom of vertical match',
        () async {
          final fireLevel = GameLevel(
            number: 1,
            timeLimit: 60,
            targetEmoji: Emojis.fire,
            targetAmount: 10,
            availableEmojis: [Emojis.fire, Emojis.rock],
            goal: 'test',
            description: 'test',
          );

          testGrid.fillPattern([
            Emojis.droplet,
            Emojis.spider,
            Emojis.bone,
            Emojis.worm,
          ]);
          testGrid.place(0, 0, Emojis.fire);
          testGrid.place(1, 0, Emojis.fire);
          testGrid.place(2, 0, Emojis.rock);
          testGrid.place(3, 0, Emojis.fire);

          final hint = await HintDetector.findBestMove(
            grid: grid,
            targetEmoji: fireLevel.targetEmoji,
          );

          expect(hint, isNotNull);
          expect(
            hint![2].row,
            equals(3),
            reason: "Completing tile row should be 3",
          );
          expect(
            hint[2].col,
            equals(0),
            reason: "Completing tile col should be 0",
          );
        },
      );

      test(
        'Should identify completing tile at top of vertical match',
        () async {
          final fireLevel = GameLevel(
            number: 1,
            timeLimit: 60,
            targetEmoji: Emojis.fire,
            targetAmount: 10,
            availableEmojis: [Emojis.fire, Emojis.rock],
            goal: 'test',
            description: 'test',
          );

          testGrid.fillPattern([
            Emojis.droplet,
            Emojis.spider,
            Emojis.bone,
            Emojis.worm,
          ]);
          testGrid.place(0, 0, Emojis.fire);
          testGrid.place(1, 0, Emojis.rock);
          testGrid.place(2, 0, Emojis.fire);
          testGrid.place(3, 0, Emojis.fire);

          final hint = await HintDetector.findBestMove(
            grid: grid,
            targetEmoji: fireLevel.targetEmoji,
          );

          expect(hint, isNotNull);
          expect(
            hint![2].row,
            equals(0),
            reason: "Completing tile row should be 0 (the Fire moving in)",
          );
          expect(
            hint[2].col,
            equals(0),
            reason: "Completing tile col should be 0",
          );
        },
      );
    });

    group('Scoring — target ingredient preference', () {
      test(
        'Should prefer a move that matches target ingredient over a plain match',
        () async {
          testGrid.fillPattern([
            Emojis.alien,
            Emojis.rock,
            Emojis.droplet,
            Emojis.alien,
          ]);

          grid[0][0].emoji = Emojis.fire;
          grid[0][1].emoji = Emojis.fire;
          grid[0][2].emoji = Emojis.fire;

          grid[7][0].emoji = Emojis.rock;
          grid[7][1].emoji = Emojis.rock;
          grid[7][2].emoji = Emojis.rock;

          final hint = await HintDetector.findBestMove(
            grid: grid,
            targetEmoji: level.targetEmoji,
          );

          expect(hint, isNotNull);
          expect(
            hint![0].row,
            0,
            reason:
                'The hint should point to row 0 (fire match) since fire is the bomb ingredient',
          );
        },
      );
    });

    group('Scoring — direct target yield preference', () {
      test(
        'Should prefer a match whose emoji is the target over a non-target match',
        () async {
          final fireLevel = GameLevel(
            number: 1,
            timeLimit: 60,
            targetEmoji: Emojis.fire,
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

          for (int r = 0; r < BoardManager.rows; r++) {
            for (int c = 0; c < BoardManager.cols; c++) {
              grid[r][c].emoji = (r + c) % 2 == 0 ? Emojis.alien : Emojis.rock;
            }
          }
          grid[0][0].emoji = Emojis.droplet;
          grid[0][1].emoji = Emojis.droplet;
          grid[0][2].emoji = Emojis.droplet;

          grid[7][0].emoji = Emojis.fire;
          grid[7][1].emoji = Emojis.fire;
          grid[7][2].emoji = Emojis.fire;

          final hint = await HintDetector.findBestMove(
            grid: grid,
            targetEmoji: fireLevel.targetEmoji,
          );

          expect(hint, isNotNull);
          expect(
            hint![0].row,
            7,
            reason:
                'fire row (7) beats droplet row (0): target +100 makes it unambiguous',
          );
        },
      );
    });

    group('Scoring — shape match preference', () {
      test('Should prefer an L-shape move over a plain 3-match', () async {
        testGrid.fillPattern([
          Emojis.rock,
          Emojis.droplet,
          Emojis.alien,
          Emojis.spider,
        ]);
        testGrid.place(0, 0, Emojis.fire);
        testGrid.place(0, 1, Emojis.fire);
        testGrid.place(0, 2, Emojis.fire);
        testGrid.place(1, 2, Emojis.fire);
        testGrid.place(2, 2, Emojis.fire);
        testGrid.place(6, 2, Emojis.droplet);
        testGrid.place(7, 0, Emojis.rock);
        testGrid.place(7, 1, Emojis.rock);
        testGrid.place(7, 2, Emojis.rock);

        final hint = await HintDetector.findBestMove(
          grid: grid,
          targetEmoji: level.targetEmoji,
        );

        expect(hint, isNotNull);
        expect(
          hint![0].row,
          lessThan(4),
          reason:
              'hint should be in the top half of the board (the L-shape area)',
        );
      });
    });

    group('Edge cases', () {
      test('Should not suggest swapping a tile with itself', () async {
        testGrid.fillPattern([
          Emojis.fire,
          Emojis.rock,
          Emojis.droplet,
          Emojis.alien,
        ]);
        testGrid.place(0, 0, Emojis.fire);
        testGrid.place(0, 1, Emojis.fire);
        testGrid.place(0, 2, Emojis.fire);

        final hint = await HintDetector.findBestMove(
          grid: grid,
          targetEmoji: level.targetEmoji,
        );

        expect(hint![0], isNot(equals(hint[1])));
      });

      test('Should not match hole emoji', () async {
        testGrid.fillPattern([
          Emojis.fire,
          Emojis.rock,
          Emojis.droplet,
          Emojis.alien,
        ]);
        testGrid.place(3, 0, Emojis.hole);
        testGrid.place(3, 1, Emojis.hole);
        testGrid.place(3, 2, Emojis.hole);
        testGrid.place(0, 0, Emojis.fire);
        testGrid.place(0, 1, Emojis.fire);
        testGrid.place(0, 2, Emojis.fire);

        final hint = await HintDetector.findBestMove(
          grid: grid,
          targetEmoji: level.targetEmoji,
        );

        expect(hint, isNotNull);
        expect(
          hint![0].row,
          isNot(3),
          reason: 'Must not point into the hole row',
        );
        expect(
          hint[1].row,
          isNot(3),
          reason: 'Must not point into the hole row',
        );
      });

      test(
        'Should handle a fully uniform board of one emoji gracefully',
        () async {
          testGrid.fill(Emojis.fire);

          final hint = await HintDetector.findBestMove(
            grid: grid,
            targetEmoji: level.targetEmoji,
          );

          expect(
            hint,
            isNotNull,
            reason:
                'Every swap is valid; we just want no crash and valid coords',
          );
          expect(
            hint!.length,
            3,
            reason:
                'Every swap is valid; we just want no crash and valid coords',
          );
        },
      );
    });
  });
}
