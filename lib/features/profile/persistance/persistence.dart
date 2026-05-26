import 'package:grimoji/features/profile/models/profile_data.dart';


abstract class ProfilePersistence {
  Future<ProfileData> loadProfile();

  Future<void> saveProfile(ProfileData profile);
}