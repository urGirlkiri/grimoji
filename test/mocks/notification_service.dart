import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/services/notifications/models/image.dart';
import 'package:grimoji/services/notifications/models/service.dart';

class MockNotificationService implements NotificationService {
  MockNotificationService({this.permissionGranted = true});

  final bool permissionGranted;
  final List<int> cancelledIds = [];
  final List<int> scheduledIds = [];
  final List<int> shownIds = [];

  @override
  Future<bool> areNotificationsEnabled() async => permissionGranted;

  @override
  Future<void> cancel(int id) async => cancelledIds.add(id);

  @override
  Future<void> cancelAll() async {}

  @override
  Future<NotificationResponse?> getLaunchNotificationResponse() async => null;

  @override
  Future<void> initialize({
    void Function(String? payload)? onTapPayload,
  }) async {}

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<bool> canScheduleExactAlarms() async => true;

  @override
  Future<void> requestExactAlarmPermission() async {}

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationImage? image,
  }) async {
    scheduledIds.add(id);
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationImage? image,
  }) async {
    shownIds.add(id);
  }
}
