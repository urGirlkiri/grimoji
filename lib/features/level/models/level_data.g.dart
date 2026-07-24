// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LevelDataAdapter extends TypeAdapter<LevelData> {
  @override
  final int typeId = 0;

  @override
  LevelData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LevelData(
      level: fields[0] as int,
      stars: fields[1] as int,
      crimsonStars: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, LevelData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.level)
      ..writeByte(1)
      ..write(obj.stars)
      ..writeByte(2)
      ..write(obj.crimsonStars);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
