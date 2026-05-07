import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../level_data.dart';
import 'level_data_persistence.dart';

/// An implementation of [LevelDataPersistence] that uses
/// `package:shared_preferences`.
class LocalStorageLevelDataPersistence extends LevelDataPersistence {
  static const _key = 'game_level_data';
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  @override
  Future<Map<int, LevelData>> getLevelData() async {
    final prefs = await instanceFuture;
    final json = prefs.getString(_key);
    if (json == null) return {};

    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries)
          int.parse(entry.key): LevelData.fromJson(entry.value as Map<String, dynamic>),
      };
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> saveLevelData(Map<int, LevelData> data) async {
    final prefs = await instanceFuture;
    final json = jsonEncode({
      for (final entry in data.entries)
        entry.key.toString(): entry.value.toJson(),
    });
    await prefs.setString(_key, json);
  }

  @override
  Future<int> getLevelStars(int level) async {
    final data = await getLevelData();
    return data[level]?.stars ?? 0;
  }

  @override
  Future<void> saveLevelStars(int level, int stars) async {
    final data = await getLevelData();
    data[level] = LevelData(level: level, stars: stars);
    await saveLevelData(data);
  }

  @override
  Future<void> clearAllData() async {
    final prefs = await instanceFuture;
    await prefs.remove(_key); 
  }
}
