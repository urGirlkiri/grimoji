import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/level/models/level_data.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:grimoji/features/level/models/data_persistence.dart';
import 'package:grimoji/features/level/models/hive_data_persistence.dart';

class LevelDataController extends ChangeNotifier {
  final LevelDataPersistence _store;
  final Map<int, LevelData> _levelData = {};
  int _mapVersion = 0;

  bool isInitialized = false;

  int? autoOpenLvl;
  GameEmoji? unlockedEmoji;
  String? unlockedRecipeId;

  void triggerAutoOpenLevel(int level, GameEmoji? emoji, {String? recipeId}) {
    autoOpenLvl = level;
    unlockedEmoji = emoji;
    unlockedRecipeId = recipeId;
    notifyListeners();
  }

  void clearAutoOpenLevel() {
    autoOpenLvl = null;
    unlockedEmoji = null;
    unlockedRecipeId = null;
  }

  LevelDataController({LevelDataPersistence? store})
    : _store =
          store ??
          HiveLevelDataPersistence(box: Hive.box<LevelData>('level_data')) {
    _getLatestFromStore();
  }

  int get mapVersion => _mapVersion;
  int getStars(int level) => _levelData[level]?.stars ?? 0;
  int getCrimsonStars(int level) => _levelData[level]?.crimsonStars ?? 0;

  int currentLevel() {
    _getLatestFromStore();
    if (_levelData.isEmpty) {
      return 1;
    }

    final highestReached = _levelData.keys.reduce(math.max);

    if (gameLevels.isEmpty) return highestReached + 1;

    final finalLv = gameLevels.map((lv) => lv.number).reduce(math.max);

    return highestReached >= finalLv ? finalLv : highestReached + 1;
  }

  bool isLevelCompleted(int level) => _levelData.containsKey(level);

  Future<void> saveLevelCompletion(
    int level,
    int stars, {
    int? crimsonStars,
  }) async {
    final existing = _levelData[level];

    final bestStars = math.max(stars, existing?.stars ?? 0);
    final bestCStars = math.max(
      crimsonStars ?? 0,
      existing?.crimsonStars ?? 0,
    );

    final finalCrimsonStars = bestStars == 3 ? bestCStars : null;

    _levelData[level] = LevelData(
      level: level,
      stars: bestStars,
      crimsonStars: finalCrimsonStars,
    );
    _mapVersion++;
    notifyListeners();

    await _store.saveLevelStars(level, bestStars, crimsonStars: finalCrimsonStars);
  }

  Map<int, LevelData> getAllLevelData() => Map.unmodifiable(_levelData);

  Future<void> _getLatestFromStore() async {
    try {
      final data = await _store.getLevelData();
      _levelData.clear();
      _levelData.addAll(data);
    } catch (e) {
      if (kDebugMode) print('Error loading game data: $e');
    } finally {
      isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> reset() async {
    await _store.clearAllData();
    _levelData.clear();
    await _getLatestFromStore();
    _mapVersion++;
    notifyListeners();
  }
}
