import 'package:hive/hive.dart';
import '../level_data.dart';
import 'level_data_persistence.dart';

/// An implementation of [LevelDataPersistence] that uses Hive.
class HiveLevelDataPersistence extends LevelDataPersistence {
  final Box<LevelData> _box;

  HiveLevelDataPersistence({required Box<LevelData> box}) : _box = box;

  Map<int, LevelData> get _currentData {
    final result = <int, LevelData>{};
    for (final key in _box.keys) {
      final value = _box.get(key);
      if (value != null) {
        result[key as int] = value;
      }
    }
    return result;
  }

  @override
  Future<Map<int, LevelData>> getLevelData() async => _currentData;

  @override
  Future<void> saveLevelData(Map<int, LevelData> data) async {
    await _box.putAll(data);
  }

  @override
  Future<int> getLevelStars(int level) async {
    return _currentData[level]?.stars ?? 0;
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