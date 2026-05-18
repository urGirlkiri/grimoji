import 'package:hive/hive.dart';

part 'settings_data.g.dart';

@HiveType(typeId: 1)
class SettingsData {
  @HiveField(0)
  final bool audioOn;

  @HiveField(1)
  final bool soundsOn;

  @HiveField(2)
  final bool musicOn;

  @HiveField(3)
  final double sfxVolume;

  @HiveField(4)
  final double musicVolume;

  const SettingsData({
    this.audioOn = true,
    this.soundsOn = true,
    this.musicOn = true,
    this.sfxVolume = 1.0,
    this.musicVolume = 1.0,
  });

  SettingsData copyWith({
    bool? audioOn,
    bool? soundsOn,
    bool? musicOn,
    double? sfxVolume,
    double? musicVolume,
  }) {
    return SettingsData(
      audioOn: audioOn ?? this.audioOn,
      soundsOn: soundsOn ?? this.soundsOn,
      musicOn: musicOn ?? this.musicOn,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      musicVolume: musicVolume ?? this.musicVolume,
    );
  }
}