import 'package:hive/hive.dart';
import '../level_data.dart';
import 'level_data_persistence.dart';

/// An implementation of [LevelDataPersistence] that uses Hive.
class HiveLevelDataPersistence extends LevelDataPersistence {
  final Box<LevelData> _box;

  HiveLevelDataPersistence({required Box<LevelData> box}) : _box = box;

  @override
  Future<Map<int, LevelData>> getLevelData() async {
    final result = <int, LevelData>{};
    
    for (final entry in _box.toMap().entries) {
      if (entry.key is int) {
        result[entry.key as int] = entry.value;
      } else if (entry.key is String) {
        final parsedKey = int.tryParse(entry.key as String);
        if (parsedKey != null) {
          result[parsedKey] = entry.value;
        }
      }
    }
    return result;
  }

  @override
  Future<void> saveLevelData(Map<int, LevelData> data) async {
    await _box.putAll(data);
  }

  @override
  Future<int> getLevelStars(int level) async {
    final data = _box.get(level);
    return data?.stars ?? 0;
  }

  @override
  Future<void> saveLevelStars(int level, int stars) async {
    await _box.put(level, LevelData(level: level, stars: stars));
  }

  @override
  Future<void> clearAllData() async {
    await _box.clear();
  }
}