import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'level_data.dart';
import 'persistence/level_data_persistence.dart';
import 'persistence/hive_level_data_persistence.dart';

class LevelDataController extends ChangeNotifier {
  final LevelDataPersistence _store;
  final Map<int, LevelData> _levelData = {};

  LevelDataController({LevelDataPersistence? store})
    : _store = store ?? HiveLevelDataPersistence(
        box: Hive.box<LevelData>('level_data'),
      ) {
    _getLatestFromStore();
  }

  int getStars(int level) => _levelData[level]?.stars ?? 0;

  bool isLevelCompleted(int level) => _levelData.containsKey(level);

  Future<void> saveLevelCompletion(int level, int stars) async {
    _levelData[level] = LevelData(level: level, stars: stars);
    notifyListeners();

    await _store.saveLevelStars(level, stars);
  }

  Map<int, LevelData> getAllLevelData() => Map.unmodifiable(_levelData);

  Future<void> _getLatestFromStore() async {
    try {
      final data = await _store.getLevelData();
      _levelData.clear();
      _levelData.addAll(data);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error loading game data: $e');
    }
  }

  Future<void> reset() async {
    await _store.clearAllData();
    _levelData.clear();
    notifyListeners();
  }
}
