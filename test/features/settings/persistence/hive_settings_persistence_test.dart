import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:grimoji/features/settings/persistence/hive_settings_persistence.dart';
import 'package:grimoji/features/settings/models/settings_data.dart';

void main() {
  group('HiveSettingsPersistence Tests', () {
    late HiveSettingsPersistence persistence;
    late Box<SettingsData> box;

    setUpAll(() async {
      final tempDir = await Directory.systemTemp.createTemp('hive_settings_test_dir');
      Hive.init(tempDir.path);
      Hive.registerAdapter(SettingsDataAdapter());
    });

    setUp(() async {
      box = await Hive.openBox<SettingsData>('settings_test');
      persistence = HiveSettingsPersistence(box: box);
    });

    tearDown(() async {
      await box.clear();
      await box.close();
    });

    tearDownAll(() async {
      await Hive.deleteFromDisk();
    });

    test('should return default values when no settings are saved', () async {
      expect(await persistence.getAudioOn(defaultValue: true), isTrue);
      expect(await persistence.getMusicOn(defaultValue: true), isTrue);
    });

    test('should correctly save and retrieve audio settings', () async {
      await persistence.saveAudioOn(false);
      
      final isAudioOn = await persistence.getAudioOn(defaultValue: true);
      
      expect(isAudioOn, isFalse);
    });

    test('should correctly save and retrieve a full settings payload', () async {
      await persistence.saveAudioOn(false);
      await persistence.saveMusicOn(true);
      await persistence.saveSoundsOn(true);
      await persistence.saveSfxVolume(0.8);
      await persistence.saveMusicVolume(1.0);
      
      final audioOn = await persistence.getAudioOn(defaultValue: true);
      final musicOn = await persistence.getMusicOn(defaultValue: true);
      final soundsOn = await persistence.getSoundsOn(defaultValue: true);
      final sfxVol = await persistence.getSfxVolume(defaultValue: 1.0);
      final musicVol = await persistence.getMusicVolume(defaultValue: 1.0);
      
      expect(audioOn, isFalse);
      expect(musicOn, isTrue);
      expect(soundsOn, isTrue);
      expect(sfxVol, 0.8);
      expect(musicVol, 1.0);
    });
  });
}