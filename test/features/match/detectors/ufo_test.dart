import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/ufo/analyzer.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/detectors/match.dart';
import 'package:grimoji/features/match/detectors/ufo/scanner.dart';
import 'package:grimoji/features/match/detectors/ufo/scorer.dart';

import '../../../helpers/test_grid.dart';

void main() {
  group('UFO beam targeting', () {
    late BoardManager boardManager;
    late TestGrid testGrid;
    late Set<String> unmatchableVisuals;
    late Map<String, int> recipeChainSteps;

    setUp(() {
      RecipeBook.initialize();

      final level = GameLevel(
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
      );

      boardManager = BoardManager(level);
      boardManager.initialize();
      testGrid = TestGrid(boardManager);
      testGrid.fill(Emojis.hole);

      unmatchableVisuals = MatchDetector.unmatchableEmojis
          .map((e) => e.visual)
          .toSet();
      recipeChainSteps = RecipeBook.getRecipeChainSteps(
        Emojis.bomb,
      ).map((emoji, step) => MapEntry(emoji.visual, step));
    });

    test('collapseColumnAfterRemoval drops the cell and blanks the top', () {
      final board = [
        ['a', 'x', 'p'],
        ['b', 'y', 'q'],
        ['c', 'z', 'r'],
      ];

      final result = collapseColumnAfterRemoval(board, row: 1, col: 1);

      expect(result[0], ['a', '', 'p']);
      expect(result[1], ['b', 'x', 'q']);
      expect(result[2], ['c', 'z', 'r']);
    });

    test('scoreAbductCandidate rewards dead unmatchable tiles', () {
      final score = scoreAbductCandidate(
        boardManager.gridTiles,
        row: 3,
        col: 3,
        targetVisual: 'nonexistent',
        unmatchableVisuals: unmatchableVisuals,
        recipeChainSteps: recipeChainSteps,
      );

      expect(score, equals(deadTileBonus));
    });

    test('scoreAbductCandidate penalizes collectible powerup tiles', () {
      boardManager.gridTiles[3][3].isCollectiblePowerup = true;

      final score = scoreAbductCandidate(
        boardManager.gridTiles,
        row: 3,
        col: 3,
        targetVisual: 'nonexistent',
        unmatchableVisuals: unmatchableVisuals,
        recipeChainSteps: recipeChainSteps,
      );

      expect(score, equals(deadTileBonus - abductPowerupPenalty));
    });

    test('scoreExplosiveCandidate rewards tiles near explosive reactions', () {
      testGrid.place(4, 4, Emojis.bomb);

      final nearScore = scoreExplosiveCandidate(
        boardManager.gridTiles,
        row: 4,
        col: 3,
        targetVisual: 'nonexistent',
        unmatchableVisuals: unmatchableVisuals,
        recipeChainSteps: recipeChainSteps,
      );
      final farScore = scoreExplosiveCandidate(
        boardManager.gridTiles,
        row: 0,
        col: 0,
        targetVisual: 'nonexistent',
        unmatchableVisuals: unmatchableVisuals,
        recipeChainSteps: recipeChainSteps,
      );

      expect(
        nearScore - farScore,
        greaterThanOrEqualTo(reactionAdjacencyBonus),
      );
    });

    test('UFOAnalyzer returns aligned beam plan sorted by column', () async {
      final plan = await UFOAnalyzer.analyzeBoard(
        grid: boardManager.gridTiles,
        targetEmoji: Emojis.bomb,
      );

      expect(plan.targets.length, equals(3));
      expect(plan.beamTypes.length, equals(3));
      expect(plan.beamDelays.length, equals(3));
      expect(plan.tileIds.length, equals(3));

      for (int i = 1; i < plan.targets.length; i++) {
        expect(
          plan.targets[i].col,
          greaterThanOrEqualTo(plan.targets[i - 1].col),
        );
      }

      for (int i = 0; i < plan.targets.length; i++) {
        final tile =
            boardManager.gridTiles[plan.targets[i].row][plan.targets[i].col];
        expect(tile.id, equals(plan.tileIds[i]));
      }
    });

    test(
      'UFOAnalyzer falls back when every tile is the target emoji',
      () async {
        testGrid.fill(Emojis.bomb);

        final plan = await UFOAnalyzer.analyzeBoard(
          grid: boardManager.gridTiles,
          targetEmoji: Emojis.bomb,
        );

        expect(plan.targets.length, equals(3));
        expect(plan.tileIds, isEmpty);
      },
    );
  });
}
