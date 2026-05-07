import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'level_data.dart';
import 'persistence/level_data_persistence.dart';
import 'persistence/local_storage_level_data_persistence.dart';

/// Manages game level data including stars and persistence.
class LevelDataController extends ChangeNotifier {
  final LevelDataPersistence _store;
  final Map<int, LevelData> _levelData = {};

  LevelDataController({LevelDataPersistence? store})
    : _store = store ?? LocalStorageLevelDataPersistence() {
    _getLatestFromStore();
  }

  int getStars(int level) => _levelData[level]?.stars ?? 0;

  bool isLevelCompleted(int level) => _levelData.containsKey(level);

  Future<void> completeLevelWithStars(int level) async {
    final random = Random();
    final stars = random.nextInt(3) + 1; // Random between 1 and 3

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
    _levelData.clear();
    notifyListeners();
    await _store.clearAllData();
  }
}
