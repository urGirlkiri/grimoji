import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/features/profile/models/profile_data.dart';
import 'package:grimoji/features/profile/persistance/persistence.dart';

class MockProfilePersistence implements ProfilePersistence {
  MockProfilePersistence(this.profile);

  ProfileData profile;

  @override
  Future<ProfileData> loadProfile() async => profile;

  @override
  Future<void> saveProfile(ProfileData value) async {
    profile = value;
  }
}
