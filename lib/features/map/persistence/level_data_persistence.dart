import '../level_data.dart';

abstract class LevelDataPersistence {
  Future<Map<int, LevelData>> getLevelData();

  Future<void> saveLevelData(Map<int, LevelData> data);

  Future<int> getLevelStars(int level);

  Future<void> saveLevelStars(int level, int stars);

  Future<void> clearAllData();
}
