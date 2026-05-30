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
      avatar: fields[1] as String,
      unlockedRecipeIds: (fields[2] as List).cast<String>(),
      unreadRecipeIds: (fields[3] as List).cast<String>(),
      cauldrons: fields[4] as int,
      lastCauldronRegenTime: fields[5] as int,
      lastPlayedGameTime: fields[8] as int,
      dices: fields[7] as int,
      inventory: (fields[6] as Map).cast<String, int>(),
      hasClaimedDaily: fields[9] == null ? false : fields[9] as bool,
      lastDailyClaimTime: fields[10] == null ? 0 : fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileData obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.isFirstTime)
      ..writeByte(1)
      ..write(obj.avatar)
      ..writeByte(2)
      ..write(obj.unlockedRecipeIds)
      ..writeByte(3)
      ..write(obj.unreadRecipeIds)
      ..writeByte(4)
      ..write(obj.cauldrons)
      ..writeByte(5)
      ..write(obj.lastCauldronRegenTime)
      ..writeByte(6)
      ..write(obj.inventory)
      ..writeByte(7)
      ..write(obj.dices)
      ..writeByte(8)
      ..write(obj.lastPlayedGameTime)
      ..writeByte(9)
      ..write(obj.hasClaimedDaily)
      ..writeByte(10)
      ..write(obj.lastDailyClaimTime);
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
