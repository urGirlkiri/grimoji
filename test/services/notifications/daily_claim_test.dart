import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/services/notifications/daily_claim.dart';

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

    test('scheduleTestReminder should not throw before initialization', () async {
      final reminder = DailyClaimReminder();
      await expectLater(
        reminder.scheduleTestReminder(const Duration(seconds: 1)),
        completes,
      );
    });
  });
}
