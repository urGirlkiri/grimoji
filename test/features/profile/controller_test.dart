import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/features/profile/models/profile_data.dart';
import 'package:grimoji/features/profile/persistance/persistence.dart';

class _FakeProfilePersistence implements ProfilePersistence {
  ProfileData? _profile;

  @override
  Future<ProfileData> loadProfile() async => _profile ?? ProfileData();

  @override
  Future<void> saveProfile(ProfileData profile) async {
    _profile = profile;
  }
}

void main() {
  group('Recipe Collections', () {
    test('should hide a staged recipe from displayUnreadRecipeCount', () async {
      final persistence = _FakeProfilePersistence();
      final controller = ProfileController(persistence: persistence);
      await controller.load();

      controller.unlockRecipe('recipe_1');
      expect(controller.unreadRecipeCount, 1);
      expect(controller.displayUnreadRecipeCount, 1);

      controller.stageRecipeCollection('recipe_1');
      expect(controller.unreadRecipeCount, 1);
      expect(controller.displayUnreadRecipeCount, 0);
    });

    test(
      'should restore displayUnreadRecipeCount when recipe collection completes',
      () async {
        final persistence = _FakeProfilePersistence();
        final controller = ProfileController(persistence: persistence);
        await controller.load();

        controller.unlockRecipe('recipe_1');
        controller.stageRecipeCollection('recipe_1');
        expect(controller.displayUnreadRecipeCount, 0);

        controller.completeRecipeCollection('recipe_1');
        expect(controller.displayUnreadRecipeCount, 1);
        expect(controller.unreadRecipeCount, 1);
      },
    );

    test(
      'should ignore pending collections for recipes that are no longer unread',
      () async {
        final persistence = _FakeProfilePersistence();
        final controller = ProfileController(persistence: persistence);
        await controller.load();

        controller.unlockRecipe('recipe_1');
        controller.stageRecipeCollection('recipe_1');
        controller.markRecipeAsRead('recipe_1');

        expect(controller.unreadRecipeCount, 0);
        expect(controller.displayUnreadRecipeCount, 0);
      },
    );

    test(
      'should compute displayUnreadRecipeCount correctly with multiple pending collections',
      () async {
        final persistence = _FakeProfilePersistence();
        final controller = ProfileController(persistence: persistence);
        await controller.load();

        controller.unlockRecipe('recipe_1');
        controller.unlockRecipe('recipe_2');
        expect(controller.unreadRecipeCount, 2);

        controller.stageRecipeCollection('recipe_1');
        expect(controller.displayUnreadRecipeCount, 1);

        controller.completeRecipeCollection('recipe_1');
        expect(controller.displayUnreadRecipeCount, 2);
      },
    );
  });

  group('Avatar', () {
    test('should update avatar when given a valid avatar id', () async {
      final persistence = _FakeProfilePersistence();
      final controller = ProfileController(persistence: persistence);
      await controller.load();

      expect(controller.avatar, 'cyber_goth');

      controller.setAvatar('fairy_mage');
      expect(controller.avatar, 'fairy_mage');
    });

    test('should ignore invalid avatar ids', () async {
      final persistence = _FakeProfilePersistence();
      final controller = ProfileController(persistence: persistence);
      await controller.load();

      controller.setAvatar('not_an_avatar');
      expect(controller.avatar, 'cyber_goth');
    });

    test('should default displayName to formatted avatar name', () async {
      final persistence = _FakeProfilePersistence();
      final controller = ProfileController(persistence: persistence);
      await controller.load();

      expect(controller.displayName, 'Cyber Goth');
    });

    test('should keep custom displayName when avatar changes', () async {
      final persistence = _FakeProfilePersistence();
      final controller = ProfileController(persistence: persistence);
      await controller.load();

      controller.setDisplayName('God Speed');
      controller.setAvatar('fairy_mage');

      expect(controller.displayName, 'God Speed');
    });
  });

  group('Daily Claim Reminder', () {
    test('should invoke callback with next claim time when claiming', () async {
      final persistence = _FakeProfilePersistence();
      DateTime? capturedNextClaimTime;
      final controller = ProfileController(
        persistence: persistence,
        onDailyClaim: (nextClaimTime) {
          capturedNextClaimTime = nextClaimTime;
        },
      );
      await controller.load();

      final beforeClaim = DateTime.now();
      controller.claimDailyReward();

      expect(capturedNextClaimTime, isNotNull);
      expect(
        capturedNextClaimTime!.difference(beforeClaim),
        greaterThanOrEqualTo(const Duration(hours: 23, minutes: 59)),
      );
    });
  });
}
