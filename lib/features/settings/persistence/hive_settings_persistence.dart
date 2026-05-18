import 'package:hive/hive.dart';
import 'settings_data.dart';
import 'settings_persistence.dart';

/// An implementation of [SettingsPersistence] that uses Hive.
class HiveSettingsPersistence extends SettingsPersistence {
  final Box<SettingsData> _box;

  HiveSettingsPersistence({required Box<SettingsData> box}) : _box = box;

  SettingsData get _currentData => _box.get('settings') ?? const SettingsData();

  @override
  Future<bool> getAudioOn({required bool defaultValue}) async => _currentData.audioOn;

  @override
  Future<bool> getMusicOn({required bool defaultValue}) async => _currentData.musicOn;

  @override
  Future<bool> getSoundsOn({required bool defaultValue}) async => _currentData.soundsOn;

  @override
  Future<double> getSfxVolume({required double defaultValue}) async => _currentData.sfxVolume;

  @override
  Future<double> getMusicVolume({required double defaultValue}) async => _currentData.musicVolume;

  @override
  Future<void> saveAudioOn(bool value) async {
    await _box.put('settings', _currentData.copyWith(audioOn: value));
  }

  @override
  Future<void> saveMusicOn(bool value) async {
    await _box.put('settings', _currentData.copyWith(musicOn: value));
  }

  @override
  Future<void> saveSoundsOn(bool value) async {
    await _box.put('settings', _currentData.copyWith(soundsOn: value));
  }

  @override
  Future<void> saveSfxVolume(double value) async {
    await _box.put('settings', _currentData.copyWith(sfxVolume: value));
  }

  @override
  Future<void> saveMusicVolume(double value) async {
    await _box.put('settings', _currentData.copyWith(musicVolume: value));
  }

  @override
  Future<void> saveAllSettings({
    bool? audioOn,
    bool? soundsOn,
    bool? musicOn,
    double? sfxVolume,
    double? musicVolume,
  }) async {
    final current = _currentData;
    await _box.put('settings', current.copyWith(
      audioOn: audioOn,
      soundsOn: soundsOn,
      musicOn: musicOn,
      sfxVolume: sfxVolume,
      musicVolume: musicVolume,
    ));
  }
}