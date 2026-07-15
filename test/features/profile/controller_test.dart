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
}
