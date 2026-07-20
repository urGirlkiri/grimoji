import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/features/profile/models/profile_data.dart';
import 'package:grimoji/services/notifications/daily_claim.dart';

import '../../mocks/notification_service.dart';
import '../../mocks/profile_persistence.dart';

void main() {
  group('DailyClaimReminder', () {
    test('cancelReminder should not throw before initialization', () async {
      final reminder = DailyClaimReminder();
      await expectLater(reminder.cancelReminder(), completes);
    });

    test(
      'scheduleReminder in the past should not throw before initialization',
      () async {
        final reminder = DailyClaimReminder();
        final past = DateTime.now().subtract(const Duration(hours: 1));
        await expectLater(reminder.scheduleReminder(past), completes);
      },
    );

    test('passes through a denied notification permission', () async {
      final reminder = DailyClaimReminder(
        service: MockNotificationService(permissionGranted: false),
        isDesktopFallback: false,
      );

      expect(await reminder.requestPermission(), isFalse);
      expect(await reminder.areNotificationsEnabled(), isFalse);
    });

    test('schedules and cancels a daily reminder', () async {
      final service = MockNotificationService();
      final reminder = DailyClaimReminder(
        service: service,
        isDesktopFallback: false,
      );

      await reminder.scheduleReminder(
        DateTime.now().add(const Duration(hours: 1)),
      );
      await reminder.cancelReminder();

      expect(service.scheduledIds, [1]);
      expect(service.cancelledIds, [1, 1]);
    });

    test('shows one catch up reminder for an available daily claim', () async {
      final service = MockNotificationService();
      final persistence = MockProfilePersistence(
        ProfileData(
          hasClaimedDaily: true,
          lastDailyClaimTime: DateTime.now()
              .subtract(const Duration(hours: 25))
              .millisecondsSinceEpoch,
        ),
      );
      final profile = ProfileController(persistence: persistence);
      await profile.load();
      final reminder = DailyClaimReminder(
        service: service,
        isDesktopFallback: true,
      );

      await reminder.showCatchUpReminder(profile);
      await reminder.showCatchUpReminder(profile);

      expect(service.shownIds, [3]);
    });
  });
}
