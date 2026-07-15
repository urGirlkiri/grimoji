import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/levels/difficulty.dart';

void main() {
  group('LevelDifficulty', () {
    test('prankChanceFor should be 0 on even levels', () {
      expect(LevelDifficulty.prankChanceFor(2), 0.0);
      expect(LevelDifficulty.prankChanceFor(84), 0.0);
    });

    test('prankChanceFor should reach 1.0 at the last odd level (85)', () {
      expect(LevelDifficulty.prankChanceFor(85), 1.0);
    });

    test('prankChanceFor should scale linearly across odd levels', () {
      expect(LevelDifficulty.prankChanceFor(1), closeTo(1 / 43, 0.0001));
      expect(LevelDifficulty.prankChanceFor(43), closeTo(22 / 43, 0.0001));
      expect(LevelDifficulty.prankChanceFor(85), closeTo(43 / 43, 0.0001));
    });

    test('clownChanceFor should be 0 on odd levels', () {
      expect(LevelDifficulty.clownChanceFor(1), 0.0);
      expect(LevelDifficulty.clownChanceFor(85), 0.0);
    });

    test('clownChanceFor should reach 1.0 at the last even level (84)', () {
      expect(LevelDifficulty.clownChanceFor(84), 1.0);
    });

    test('clownChanceFor should scale linearly across even levels', () {
      expect(LevelDifficulty.clownChanceFor(2), closeTo(1 / 42, 0.0001));
      expect(LevelDifficulty.clownChanceFor(42), closeTo(21 / 42, 0.0001));
      expect(LevelDifficulty.clownChanceFor(84), closeTo(42 / 42, 0.0001));
    });
  });
}
