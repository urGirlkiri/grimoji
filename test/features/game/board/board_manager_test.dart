import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/game/board/utils/manager.dart';
import 'package:grimoji/features/game/board/models/coordinate.dart';
import 'package:grimoji/features/game/utils/match_detector.dart';

void main() {
  group('BoardManager Tests', () {
    late BoardManager boardManager;
    late GameLevel testLevel;

    setUp(() {
      testLevel = const GameLevel(
        number: 1,
        timeLimit: 60,
        targetEmoji: Emojis.ocean,
        targetAmount: 1,
        availableEmojis: [Emojis.droplet, Emojis.fire, Emojis.rock],
        goal: 'Test goal',
        description: 'Test description',
      );
      boardManager = BoardManager(testLevel);
      boardManager.initialize();
    });

    test('Should initialize an 8x5 board with NO immediate matches', () {
      expect(boardManager.gridTiles.length, 8);
      final initialMatches = MatchDetector.findMatchedGroups(boardManager.gridTiles);
      expect(initialMatches.isEmpty, isTrue);
    });

    test('swapTiles should swap positions in the array AND update internal tile coordinates', () {
      final tileA = boardManager.gridTiles[0][0];
      final tileB = boardManager.gridTiles[0][1];
      
      final originalEmojiA = tileA.emoji;
      final originalEmojiB = tileB.emoji;

      boardManager.swapTiles(TileCoordinate(row: 0, col: 0), TileCoordinate(row: 0, col: 1));

      expect(boardManager.gridTiles[0][0].emoji, originalEmojiB, reason: 'Tile A should now be in Tile B\'s original position');
      expect(boardManager.gridTiles[0][1].emoji, originalEmojiA, reason: 'Tile B should now be in Tile A\'s original position');

      expect(boardManager.gridTiles[0][0].coordinate.col, 0, reason: 'Tile A\'s internal coordinate should update to its new position');
      expect(boardManager.gridTiles[0][1].coordinate.col, 1, reason: 'Tile B\'s internal coordinate should update to its new position');
    });

    test('applyGravity should pull tiles down and spawn new ones at the top', () {
      final tileAbove = boardManager.gridTiles[6][0].emoji;

      final tilesToDestroy = {TileCoordinate(row: 7, col: 0)};

      boardManager.applyGravity(tilesToDestroy);

      expect(boardManager.gridTiles[7][0].emoji, tileAbove, reason: 'Gravity failed to pull the tile down');

      expect(testLevel.availableEmojis.contains(boardManager.gridTiles[0][0].emoji), isTrue, reason: 'A new tile should have spawned at the top with a valid emoji');
    });

    test('triggerInitialFall should reset all row coordinates to their final landing spots', () {
      boardManager.gridTiles[3][3].coordinate.row = -5;

      boardManager.triggerInitialFall();

      expect(boardManager.gridTiles[3][3].coordinate.row, 3, reason: 'coordinate.row should snap back to its actual row after falling');
    });

    group('Adjacency Finders', () {
      test('findAdjacentFilledTile should find a neighbor', () {
      final neighbor = boardManager.findAdjacentFilledTile(4, 2);
        
      expect(neighbor, isNotNull);
        final dx = (neighbor!.x - 4).abs();
        final dy = (neighbor.y - 2).abs();
        expect(dx + dy, 1, reason: 'Neighbor must be exactly 1 step away (no diagonals)');
      });

      test('findAdjacentEmptyTile should return null on a full board', () {
        final emptySpace = boardManager.findAdjacentEmptyTile(4, 2);
        
        expect(emptySpace, isNull);
      });

      test('findAdjacentEmptyTile should return a coordinate when an empty tile exists', () {
        const emptyEmoji = GameEmoji('svg/empty.svg', 'lottie/empty.json', '');
        
        boardManager.gridTiles[4][3].emoji = emptyEmoji;

        final emptySpace = boardManager.findAdjacentEmptyTile(4, 2);
        
        expect(emptySpace, isNotNull, reason: 'Should find the empty tile we just placed');
        expect(emptySpace!.x, equals(4));
        expect(emptySpace.y, equals(3));
      });
    });

    group('Flying Tiles', () {
      
      test('collectFlyingTiles should return false if nothing is flying', () {
        final result = boardManager.collectFlyingTiles();
        expect(result, isFalse, reason: 'Should return false when no tiles are isFlying');
      });

      test('collectFlyingTiles should return true and trigger gravity when tiles are flying', () {
        boardManager.gridTiles[7][2].isFlying = true;
        final tileAbove = boardManager.gridTiles[6][2].emoji;

        final result = boardManager.collectFlyingTiles();
        
        expect(result, isTrue, reason: 'Should return true because it found a flying tile');
        expect(boardManager.gridTiles[7][2].isFlying, isFalse, reason: 'Tile should no longer be flying after collection');
        expect(boardManager.gridTiles[7][2].emoji, equals(tileAbove), reason: 'Gravity should have pulled the tile above down into the empty space');
      });
    });

    group('Swap & Memory Tests', () {
      test('swapTiles correctly moves tiles and updates coordinates via copyWith', () {
        boardManager.gridTiles[0][0].emoji = Emojis.fire;
        boardManager.gridTiles[0][1].emoji = Emojis.droplet;

        final tileA = boardManager.gridTiles[0][0];
        final tileB = boardManager.gridTiles[0][1];

        final idA = tileA.id;
        final idB = tileB.id;
        final hashA = tileA.hashCode;
        final hashB = tileB.hashCode;

        boardManager.swapTiles(
          TileCoordinate(row: 0, col: 0),
          TileCoordinate(row: 0, col: 1),
        );

        final newTileA = boardManager.gridTiles[0][1];
        final newTileB = boardManager.gridTiles[0][0]; 

        expect(newTileA.emoji, Emojis.fire, reason: 'Tile A did not move to column 1');
        expect(newTileB.emoji, Emojis.droplet, reason: 'Tile B did not move to column 0');

        expect(newTileA.hashCode, isNot(equals(hashA)), reason: 'Tile A was mutated instead of copied!');
        expect(newTileB.hashCode, isNot(equals(hashB)), reason: 'Tile B was mutated instead of copied!');

        expect(newTileA.id, equals(idA), reason: 'Tile A lost its unique ID during copyWith');
        expect(newTileB.id, equals(idB), reason: 'Tile B lost its unique ID during copyWith');

        expect(newTileA.coordinate.row, 0);
        expect(newTileA.coordinate.col, 1);
        
        expect(newTileB.coordinate.row, 0);
        expect(newTileB.coordinate.col, 0);
      });
    });

  });
}