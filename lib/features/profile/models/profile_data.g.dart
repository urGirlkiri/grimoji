// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProfileDataAdapter extends TypeAdapter<ProfileData> {
  @override
  final int typeId = 3;

  @override
  ProfileData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProfileData(
      isFirstTime: fields[0] as bool,
      unlockedRecipeIds: (fields[1] as List).cast<String>(),
      unreadRecipeIds: (fields[2] as List).cast<String>(),
      cauldrons: fields[3] as int,
      lastCauldronRegenTime: fields[4] as int,
      inventory: (fields[5] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProfileData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.isFirstTime)
      ..writeByte(1)
      ..write(obj.unlockedRecipeIds)
      ..writeByte(2)
      ..write(obj.unreadRecipeIds)
      ..writeByte(3)
      ..write(obj.cauldrons)
      ..writeByte(4)
      ..write(obj.lastCauldronRegenTime)
      ..writeByte(5)
      ..write(obj.inventory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
