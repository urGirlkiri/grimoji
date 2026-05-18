import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:grimoji/features/level/models/level_data.dart';
import 'package:grimoji/features/level/models/hive_data_persistence.dart';

void main() {
  group('HiveLevelDataPersistence Tests', () {
    late HiveLevelDataPersistence persistence;
    late Box<LevelData> box;

    setUpAll(() async {
      final tempDir = await Directory.systemTemp.createTemp('hive_test_dir');
      Hive.init(tempDir.path);
      
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(LevelDataAdapter());
      }
    });

    setUp(() async {
      box = await Hive.openBox<LevelData>('level_data_test');
      persistence = HiveLevelDataPersistence(box: box);
    });

    tearDown(() async {
      await box.clear();
      await box.close();
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    test('should return empty map when no data is saved', () async {
      final result = await persistence.getLevelData();
      expect(result, isEmpty);
    });

    test('should save and correctly retrieve level data', () async {
      await persistence.saveLevelStars(1, 3);
      
      final retrievedData = await persistence.getLevelData();
      
      expect(retrievedData[1], isNotNull);
      expect(retrievedData[1]!.level, 1);
      expect(retrievedData[1]!.stars, 3);
    });

    test('should retrieve all completed levels as a map', () async {
      await persistence.saveLevelStars(1, 3);
      await persistence.saveLevelStars(2, 2);
      await persistence.saveLevelStars(3, 1);

      final allLevels = await persistence.getLevelData();

      expect(allLevels.length, 3);
      expect(allLevels[2]!.stars, 2);
    });

    test('should clear all data when reset is called', () async {
      await persistence.saveLevelStars(1, 3);
      
      expect(box.isEmpty, isFalse);
      
      await persistence.clearAllData();
      
      expect(box.isEmpty, isTrue);
    });
  });
}