import 'package:grimoji/config/levels/index.dart';

class LevelDifficulty {
  static final int _totalLevels = gameLevels.length;
  static final int _oddLevelCount = (_totalLevels + 1) ~/ 2;
  static final int _evenLevelCount = _totalLevels ~/ 2;

  /// Chance that an imp/prankster (`Emojis.impSmile`) spawns or sabotages.
  /// Active only on odd levels; scales linearly from level 1 to the last odd
  /// level (level 85) where it reaches 1.0.
  static double prankChanceFor(int levelNumber) {
    if (levelNumber.isEven || _oddLevelCount == 0) return 0.0;
    final index = (levelNumber + 1) ~/ 2;
    return index / _oddLevelCount;
  }

  /// Chance that a clown (`Emojis.clown`) spawns during gravity.
  /// Active only on even levels; scales linearly from level 2 to the last even
  /// level (level 84) where it reaches 1.0.
  static double clownChanceFor(int levelNumber) {
    if (levelNumber.isOdd || _evenLevelCount == 0) return 0.0;
    final index = levelNumber ~/ 2;
    return index / _evenLevelCount;
  }

  /// Chance that a barber pole (`Emojis.barberPole`) spawns at level start.
  /// Starts high on early levels and decreases linearly to 0.25 at the final level.
  static double barberChanceFor(int levelNumber) {
    if (_totalLevels == 0) return 0.0;
    return 0.5 - (levelNumber / _totalLevels) * 0.25;
  }
}
