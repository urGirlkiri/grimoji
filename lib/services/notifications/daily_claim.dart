import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/services/notifications/models/image.dart';
import 'package:grimoji/services/notifications/models/service.dart';
import 'package:grimoji/services/notifications/index.dart';

class DailyClaimReminder {
  static const String _channelId = 'daily_claim_reminder';
  static const String _channelName = 'Daily Claim Reminder';
  static const String _channelDescription =
      'Notifies you when free daily dice claim is available.';
  static const int _notificationId = 1;
  static const String _payload = Routes.marketRoute;
  static const String _title = 'Daily Reward Ready';
  static const String _body = 'Your free daily dice claim is now available!';
  static const NotificationImage _diceImage = NotificationImage(
    androidDrawable: 'dice',
    iosAssetName: 'dice.png',
    assetPath: 'assets/images/dice.png',
  );

  final NotificationService _service;
  Timer? _linuxFallbackTimer;
  void Function(String? payload)? _onTapPayload;
  bool _initialized = false;

  bool get _isLinuxFallback => !kIsWeb && Platform.isLinux;

  DailyClaimReminder({NotificationService? service})
    : _service =
          service ??
          FlutterNotificationService(
            defaultChannel: const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDescription,
              importance: Importance.defaultImportance,
            ),
          );

  Future<void> initialize({
    void Function(String? payload)? onTapPayload,
  }) async {
    _onTapPayload = onTapPayload;
    _initialized = true;

    await _service.initialize(
      onTapPayload: (payload) => _onTapPayload?.call(payload),
    );
  }

  Future<bool> requestPermission() => _service.requestPermission();

  Future<bool> areNotificationsEnabled() => _service.areNotificationsEnabled();

  Future<void> showDailyClaimNotification() async {
    await _service.show(
      id: _notificationId,
      title: _title,
      body: _body,
      payload: _payload,
      image: _diceImage,
    );
  }

  Future<void> scheduleReminder(DateTime nextClaimTime) async {
    await cancelReminder();

    if (nextClaimTime.isBefore(DateTime.now())) return;

    if (_isLinuxFallback) {
      _scheduleLinuxFallback(nextClaimTime);
      return;
    }

    await _service.schedule(
      id: _notificationId,
      title: _title,
      body: _body,
      scheduledDate: nextClaimTime,
      payload: _payload,
      image: _diceImage,
    );
  }

  Future<void> scheduleTestReminder(Duration delay) async {
    await cancelReminder();

    final scheduledDate = DateTime.now().add(delay);

    if (_isLinuxFallback) {
      _scheduleLinuxFallback(scheduledDate);
      return;
    }

    await _service.schedule(
      id: _notificationId,
      title: _title,
      body: _body,
      scheduledDate: scheduledDate,
      payload: _payload,
      image: _diceImage,
    );
  }

  Future<void> cancelReminder() async {
    _linuxFallbackTimer?.cancel();
    _linuxFallbackTimer = null;
    await _service.cancel(_notificationId);
  }

  Future<void> rescheduleFromProfile(ProfileController profile) async {
    if (!profile.canClaimDaily()) {
      final nextClaim = DateTime.fromMillisecondsSinceEpoch(
        profile.lastDailyClaimTime,
      ).add(const Duration(hours: 24));
      await scheduleReminder(nextClaim);
    } else {
      await cancelReminder();
    }
  }

  Future<void> handleLaunchNotification() async {
    if (!_initialized) return;
    final response = await _service.getLaunchNotificationResponse();
    if (response != null && response.payload == _payload) {
      _onTapPayload?.call(response.payload);
    }
  }

  void _scheduleLinuxFallback(DateTime scheduledDate) {
    _linuxFallbackTimer?.cancel();
    final delay = scheduledDate.difference(DateTime.now());
    if (delay.isNegative) return;

    _linuxFallbackTimer = Timer(delay, () async {
      await _service.show(
        id: _notificationId,
        title: _title,
        body: _body,
        payload: _payload,
        image: _diceImage,
      );
    });
  }
}
