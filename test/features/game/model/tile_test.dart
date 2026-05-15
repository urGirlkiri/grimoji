import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/game/model/coordinate.dart';
import 'package:grimoji/features/game/model/tile.dart';

class DummyBehavior extends EmojiBehavior {}

void main() {
  group('Tile Tests', () {
    
    test('Should generate a unique UUID if no ID is provided', () {
      final tile1 = Tile(coordinate: TileCoordinate(row: 0, col: 0), emoji: Emojis.fire);
      final tile2 = Tile(coordinate: TileCoordinate(row: 0, col: 1), emoji: Emojis.droplet);

      expect(tile1.id, isNotEmpty, reason: 'ID should be automatically generated');
      expect(tile2.id, isNotEmpty);
      expect(tile1.id, isNot(equals(tile2.id)), reason: 'Every tile must have a completely unique UUID');
    });

    test('Should use the provided ID if passed in the constructor', () {
      const customId = 'custom-tile-id';
      final tile = Tile(
        id: customId,
        coordinate: TileCoordinate(row: 1, col: 1),
        emoji: Emojis.rock,
      );

      expect(tile.id, equals(customId), reason: 'Constructor should respect explicitly passed IDs');
    });

    test('reset() should completely clear all visual and state flags', () {
      final tile = Tile(coordinate: TileCoordinate(row: 2, col: 2), emoji: Emojis.cloud);
      
      tile.isExploding = true;
      tile.isMerging = true;
      tile.hasFlown = true;
      tile.isFlying = true;
      tile.isHinting = true;
      tile.hintPartner = TileCoordinate(row: 2, col: 3);

      tile.reset();

      expect(tile.isExploding, isFalse);
      expect(tile.isMerging, isFalse);
      expect(tile.hasFlown, isFalse);
      expect(tile.isFlying, isFalse);
      expect(tile.isHinting, isFalse);
      expect(tile.hintPartner, isNull);
    });

    test('clearBehavior() should remove the attached EmojiBehavior', () {
      final tile = Tile(
        coordinate: TileCoordinate(row: 3, col: 3), 
        emoji: Emojis.bug,
        behavior: DummyBehavior(),
      );

      expect(tile.behavior, isNotNull, reason: 'Tile should start with the behavior we gave it');

      tile.clearBehavior();

      expect(tile.behavior, isNull, reason: 'clearBehavior() should completely nullify the property');
    });

    test('toString() should format correctly for debugging logs', () {
      final tile = Tile(
        coordinate: TileCoordinate(row: 5, col: 7), 
        emoji: Emojis.alien, 
      );

      final expectedString = 'Tile(5, 7: ${Emojis.alien.visual})';
      
      expect(tile.toString(), equals(expectedString));
    });
  });
}