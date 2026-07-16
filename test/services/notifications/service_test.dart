import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/services/notifications/index.dart';

void main() {
  group('FlutterNotificationService', () {
    test('cancel should not throw before initialization', () async {
      final service = FlutterNotificationService();
      await expectLater(service.cancel(1), completes);
    });

    test('schedule in the past should not throw before initialization', () async {
      final service = FlutterNotificationService();
      final past = DateTime.now().subtract(const Duration(hours: 1));
      await expectLater(
        service.schedule(
          id: 1,
          title: 'Test',
          body: 'Test body',
          scheduledDate: past,
        ),
        completes,
      );
    });

    test('show should not throw before initialization', () async {
      final service = FlutterNotificationService();
      await expectLater(
        service.show(id: 1, title: 'Test', body: 'Test body'),
        completes,
      );
    });
  });
}
