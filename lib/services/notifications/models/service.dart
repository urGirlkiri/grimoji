import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grimoji/services/notifications/models/image.dart';

abstract class NotificationService {
  Future<void> initialize({void Function(String? payload)? onTapPayload});

  Future<bool> requestPermission();

  Future<bool> areNotificationsEnabled();

  Future<bool> canScheduleExactAlarms();

  Future<void> requestExactAlarmPermission();

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationImage? image,
  });

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationImage? image,
  });

  Future<void> cancel(int id);

  Future<void> cancelAll();

  Future<NotificationResponse?> getLaunchNotificationResponse();
}
