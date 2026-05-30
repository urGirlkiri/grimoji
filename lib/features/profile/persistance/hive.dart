import 'package:grimoji/features/profile/models/profile_data.dart';
import 'package:grimoji/features/profile/persistance/persistence.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveProfilePersistence implements ProfilePersistence {
  static const String _boxName = 'player_profile';
  static const String _profileKey = 'main_profile';

  @override
  Future<ProfileData> loadProfile() async {
    try {
      final box = await Hive.openBox<ProfileData>(_boxName);
      final profile = box.get(_profileKey);
      if (profile == null) return ProfileData();
      return profile;
    } catch (e) {
      await Hive.deleteBoxFromDisk(_boxName);
      return ProfileData();
    }
  }

  @override
  Future<void> saveProfile(ProfileData profile) async {
    final box = await Hive.openBox<ProfileData>(_boxName);
    await box.put(_profileKey, profile);
  }
}