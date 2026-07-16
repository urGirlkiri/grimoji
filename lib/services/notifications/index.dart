import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:grimoji/services/notifications/models/image.dart';
import 'package:grimoji/services/notifications/models/service.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class FlutterNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  final AndroidNotificationChannel? _defaultChannel;
  static final _log = Logger('FlutterNotificationService');
  bool _initialized = false;

  FlutterNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    AndroidNotificationChannel? defaultChannel,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _defaultChannel = defaultChannel;

  bool get _isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  bool get _isLinuxFallback => !kIsWeb && Platform.isLinux;

  @override
  Future<void> initialize({
    void Function(String? payload)? onTapPayload,
  }) async {
    _initialized = true;
    if (!_isSupported && !_isLinuxFallback) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        onTapPayload?.call(response.payload);
      },
    );

    if (Platform.isAndroid && _defaultChannel != null) {
      try {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        await androidPlugin?.createNotificationChannel(_defaultChannel);
      } catch (e) {
        _log.warning('Failed to create notification channel: $e');
      }
    }
  }

  @override
  Future<bool> requestPermission() async {
    if (!_isSupported) return false;

    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        final granted = await androidPlugin?.requestNotificationsPermission();
        return granted ?? false;
      }

      if (Platform.isIOS) {
        final iosPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();
        return await iosPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }

      if (Platform.isMacOS) {
        final macosPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin
            >();
        return await macosPlugin?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (e) {
      _log.warning('Failed to request notification permission: $e');
    }

    return false;
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    if (!_isSupported) return false;

    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        return await androidPlugin?.areNotificationsEnabled() ?? false;
      }
    } catch (e) {
      _log.warning('Failed to check notification permission status: $e');
    }

    return true;
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationImage? image,
  }) async {
    if (!_initialized) return;
    if (!_isSupported) return;

    final details = await _notificationDetails(image: image);
    final scheduledTZDateTime = tz.TZDateTime.fromMillisecondsSinceEpoch(
      tz.UTC,
      scheduledDate.millisecondsSinceEpoch,
    );

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDateTime,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      _log.warning('Failed to schedule notification: $e');
    }
  }

  @override
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationImage? image,
  }) async {
    if (!_initialized) return;
    if (!_isSupported && !_isLinuxFallback) return;

    final details = await _notificationDetails(image: image);
    try {
      await _plugin.show(id, title, body, details, payload: payload);
    } catch (e) {
      _log.warning('Failed to show notification: $e');
    }
  }

  @override
  Future<void> cancel(int id) async {
    if (!_initialized) return;
    try {
      await _plugin.cancel(id);
    } catch (e) {
      _log.warning('Failed to cancel notification: $e');
    }
  }

  @override
  Future<void> cancelAll() async {
    if (!_initialized) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      _log.warning('Failed to cancel all notifications: $e');
    }
  }

  @override
  Future<NotificationResponse?> getLaunchNotificationResponse() async {
    if (!_initialized) return null;
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      return details?.notificationResponse;
    } catch (e) {
      _log.warning('Failed to get launch notification response: $e');
      return null;
    }
  }

  Future<NotificationDetails> _notificationDetails({
    NotificationImage? image,
  }) async {
    return NotificationDetails(
      android: await _androidDetails(image: image),
      iOS: await _darwinDetails(image: image),
      macOS: await _darwinDetails(image: image),
      linux: await _linuxDetails(image: image),
    );
  }

  Future<AndroidNotificationDetails?> _androidDetails({
    NotificationImage? image,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return null;

    AndroidBitmap<Object>? largeIcon;
    if (image?.androidDrawable != null) {
      largeIcon = DrawableResourceAndroidBitmap(image!.androidDrawable!);
    } else if (image?.assetPath != null) {
      final bytes = await rootBundle.load(image!.assetPath!);
      final filePath = await _writeToPersistentFile(
        bytes.buffer.asUint8List(),
        'notification_image',
      );
      largeIcon = FilePathAndroidBitmap(filePath);
    }

    return AndroidNotificationDetails(
      _defaultChannel?.id ?? 'default_channel',
      _defaultChannel?.name ?? 'Default',
      channelDescription: _defaultChannel?.description,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      largeIcon: largeIcon,
    );
  }

  Future<DarwinNotificationDetails?> _darwinDetails({
    NotificationImage? image,
  }) async {
    if (kIsWeb || !(Platform.isIOS || Platform.isMacOS)) return null;

    List<DarwinNotificationAttachment>? attachments;
    final filePath = await _resolveImageFilePath(image);
    if (filePath != null) {
      attachments = [DarwinNotificationAttachment(filePath)];
    }

    return DarwinNotificationDetails(attachments: attachments);
  }

  Future<LinuxNotificationDetails?> _linuxDetails({
    NotificationImage? image,
  }) async {
    if (kIsWeb || !Platform.isLinux) return null;

    LinuxNotificationIcon? icon;
    final linuxPath = image?.linuxFilePath;
    final assetPath = image?.assetPath;

    if (linuxPath != null && File(linuxPath).existsSync()) {
      icon = FilePathLinuxIcon(linuxPath);
    } else if (assetPath != null) {
      icon = AssetsLinuxIcon(assetPath);
    }

    return LinuxNotificationDetails(icon: icon);
  }

  Future<String?> _resolveImageFilePath(NotificationImage? image) async {
    if (image?.linuxFilePath != null &&
        File(image!.linuxFilePath!).existsSync()) {
      return image.linuxFilePath;
    }

    final assetPath = image?.assetPath;
    if (assetPath == null) return null;

    try {
      final bytes = await rootBundle.load(assetPath);
      return _writeToPersistentFile(
        bytes.buffer.asUint8List(),
        'notification_image',
      );
    } catch (_) {
      return null;
    }
  }

  Future<String> _writeToPersistentFile(Uint8List bytes, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$name.png');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
