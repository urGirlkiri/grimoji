// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsDataAdapter extends TypeAdapter<SettingsData> {
  @override
  final int typeId = 1;

  @override
  SettingsData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SettingsData(
      audioOn: fields[0] as bool,
      soundsOn: fields[1] as bool,
      musicOn: fields[2] as bool,
      sfxVolume: fields[3] as double,
      musicVolume: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SettingsData obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.audioOn)
      ..writeByte(1)
      ..write(obj.soundsOn)
      ..writeByte(2)
      ..write(obj.musicOn)
      ..writeByte(3)
      ..write(obj.sfxVolume)
      ..writeByte(4)
      ..write(obj.musicVolume);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
