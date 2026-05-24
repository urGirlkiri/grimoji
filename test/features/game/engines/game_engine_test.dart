import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/game/board/utils/manager.dart';
import 'package:grimoji/features/game/engines/game_engine.dart';
import 'package:grimoji/features/game/board/models/coordinate.dart';
import 'package:grimoji/features/game/utils/swipe_detector.dart';

void main() {
  group('GameEngine Tests', () {
    late BoardManager boardManager;
    late GameEngine gameEngine;
    late GameLevel level;

    setUp(() {
      RecipeBook.initialize();

      level = const GameLevel(
        number: 1,
        timeLimit: 60,
        targetEmoji: Emojis.fire,
        targetAmount: 10,
        availableEmojis: [Emojis.fire, Emojis.rock, Emojis.droplet, Emojis.alien],
        goal: 'Test goal',
        description: 'Test description',
      );

      boardManager = BoardManager(level);
      boardManager.initialize();

      gameEngine = GameEngine(level: level, boardManager: boardManager);
    });

    test('Should initialize and provide grid access', () {
      gameEngine.initialize();
      
      expect(gameEngine.grid.length, 8);
      expect(gameEngine.grid[0].length, 5);
    });

    test('Should evaluate swipe and return decision', () {
      gameEngine.initialize();
      
      boardManager.gridTiles[0][0].emoji = Emojis.fire;
      boardManager.gridTiles[0][1].emoji = Emojis.fire;
      boardManager.gridTiles[0][2].emoji = Emojis.fire;

      final decision = gameEngine.evaluateSwipe(
        TileCoordinate(row: 0, col: 0),
        TileCoordinate(row: 0, col: 1),
      );

      expect(decision.type, isNot(SwipeResult.invalid));
    });

    test('Should return invalid for non-matching swipe', () {
      gameEngine.initialize();
      
      boardManager.gridTiles[0][0].emoji = Emojis.fire;
      boardManager.gridTiles[0][1].emoji = Emojis.rock;
      boardManager.gridTiles[1][0].emoji = Emojis.droplet;
      boardManager.gridTiles[1][1].emoji = Emojis.alien;

      final decision = gameEngine.evaluateSwipe(
        TileCoordinate(row: 0, col: 0),
        TileCoordinate(row: 0, col: 1),
      );

      expect(decision.type, SwipeResult.invalid);
    });

    test('Should detect possible moves', () {
      gameEngine.initialize();
      
      boardManager.gridTiles[0][0].emoji = Emojis.fire;
      boardManager.gridTiles[0][1].emoji = Emojis.fire;
      boardManager.gridTiles[0][2].emoji = Emojis.fire;

      expect(gameEngine.hasPossibleMoves(), isTrue);
    });

    test('Should get hint move when moves available', () {
      gameEngine.initialize();
      
      boardManager.gridTiles[0][0].emoji = Emojis.fire;
      boardManager.gridTiles[0][1].emoji = Emojis.fire;
      boardManager.gridTiles[0][2].emoji = Emojis.fire;

      final hint = gameEngine.getHintMove();
      expect(hint, isNotNull);
      expect(hint!.length, 2);
    });

    test('Should return null hint when no moves available', () {
      gameEngine.initialize();
      
      for (int r = 0; r < BoardManager.rows; r++) {
        for (int c = 0; c < BoardManager.cols; c++) {
          boardManager.gridTiles[r][c].emoji = [
            Emojis.fire,
            Emojis.rock,
            Emojis.droplet,
            Emojis.alien,
          ][(r * 2 + c * 3) % 4];
        }
      }

      final hint = gameEngine.getHintMove();
      expect(hint, isNull);
    });

    test('Should shuffle grid', () {
      gameEngine.initialize();
      
      final originalEmojis = boardManager.gridTiles
          .expand((row) => row.map((tile) => tile.emoji))
          .toList();

      gameEngine.shuffleGrid();

      final shuffledEmojis = boardManager.gridTiles
          .expand((row) => row.map((tile) => tile.emoji))
          .toList();

      expect(shuffledEmojis, isNot(equals(originalEmojis)));
    });

    test('Should provide grid getter', () {
      gameEngine.initialize();
      
      expect(gameEngine.grid, equals(boardManager.gridTiles));
    });
  });
}