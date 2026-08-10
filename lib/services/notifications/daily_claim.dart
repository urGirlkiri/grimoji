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
  static const String _title = 'Daily Reward Ready';
  static const String _body = 'Your free daily dice claim is now available!';
  static const NotificationImage _diceImage = NotificationImage(
    androidDrawable: 'dice',
    iosAssetName: 'dice.png',
    assetPath: 'assets/images/dice.png',
  );

  static const String _payload = Routes.marketRoute;

  static const int _notificationId = 1;
  static const int _catchUpNotificationId = 3;

  final NotificationService _service;
  final bool? _isDesktopFallbackOverride;
  Timer? _desktopFallbackTimer;
  void Function(String? payload)? _onTapPayload;
  bool _initialized = false;

  bool get _isDesktopFallback =>
      _isDesktopFallbackOverride ??
      (!kIsWeb && (Platform.isLinux || Platform.isWindows));

  DailyClaimReminder({NotificationService? service, bool? isDesktopFallback})
    : _isDesktopFallbackOverride = isDesktopFallback,
      _service =
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

  Future<bool> requestPermission() async {
    if (_isDesktopFallback) return true;
    return _service.requestPermission();
  }

  Future<bool> areNotificationsEnabled() async {
    if (_isDesktopFallback) return true;
    return _service.areNotificationsEnabled();
  }

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

    if (_isDesktopFallback) {
      _scheduleDesktopFallback(nextClaimTime);
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

  Future<void> cancelReminder() async {
    _desktopFallbackTimer?.cancel();
    _desktopFallbackTimer = null;
    await _service.cancel(_notificationId);
  }

  Future<void> showCatchUpReminder(ProfileController profile) async {
    if (!_isDesktopFallback || !profile.shouldCatchUpReminder) {
      return;
    }

    await _service.show(
      id: _catchUpNotificationId,
      title: _title,
      body: _body,
      payload: _payload,
      image: _diceImage,
    );
    await profile.markCatchUpReminder();
  }

  Future<void> rescheduleFromProfile(ProfileController profile) async {
    if (!profile.canClaimDaily()) {
      final nextClaim = DateTime.fromMillisecondsSinceEpoch(
        profile.lastDailyClaimTime,
      ).add(const Duration(hours: 24));
      await scheduleReminder(nextClaim);
    } else {
      await cancelReminder();
      await scheduleReminder(DateTime.now().add(const Duration(hours: 24)));
    }
  }

  Future<void> handleLaunchNotification() async {
    if (!_initialized) return;
    final response = await _service.getLaunchNotificationResponse();
    if (response != null && response.payload == _payload) {
      _onTapPayload?.call(response.payload);
    }
  }

  void _scheduleDesktopFallback(DateTime scheduledDate) {
    _desktopFallbackTimer?.cancel();
    final delay = scheduledDate.difference(DateTime.now());
    if (delay.isNegative) return;

    _desktopFallbackTimer = Timer(
      delay,
      () => _showDesktopFallback(_notificationId),
    );
  }

  Future<void> _showDesktopFallback(int id) {
    return _service.show(
      id: id,
      title: _title,
      body: _body,
      payload: _payload,
      image: _diceImage,
    );
  }
}
