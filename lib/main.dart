import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/features/profile/models/profile_data.dart';
import 'package:grimoji/features/profile/persistance/hive.dart';
import 'package:grimoji/features/settings/controller.dart';
import 'package:grimoji/app/index.dart';
import 'package:grimoji/config/router/index.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/services/notifications/daily_claim.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

import 'package:grimoji/features/level/models/level_data.dart';
import 'package:grimoji/features/settings/models/settings_data.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  Logger.root.level = kDebugMode ? Level.FINE : Level.INFO;
  Logger.root.onRecord.listen((record) {
    dev.log(
      record.message,
      time: record.time,
      level: record.level.value,
      name: record.loggerName,
    );
  });

  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();

  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appDir = await getApplicationSupportDirectory();
    await Hive.initFlutter(appDir.path);
  }

  Hive.registerAdapter(SettingsDataAdapter());
  Hive.registerAdapter(LevelDataAdapter());
  Hive.registerAdapter(ProfileDataAdapter());

  await Hive.openBox<SettingsData>('settings');
  await Hive.openBox<LevelData>('level_data');
  await Hive.openBox<ProfileData>('player_profile');

  final persistence = HiveProfilePersistence();
  final settingsController = SettingsController();
  await settingsController.initialized;

  final reminder = DailyClaimReminder();
  await reminder.initialize(
    onTapPayload: (payload) {
      if (payload == Routes.marketRoute) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go(Routes.marketRoute);
        });
      }
    },
  );

  final profileController = ProfileController(
    persistence: persistence,
    onDailyClaim: (nextClaimTime) async {
      if (settingsController.dailyClaimReminderOn.value &&
          await reminder.areNotificationsEnabled()) {
        await reminder.scheduleReminder(nextClaimTime);
      } else {
        await settingsController.setDailyClaimReminderOn(false);
        await reminder.cancelReminder();
      }
    },
  );

  await profileController.load();
  profileController.checkCauldronRegen();

  if (settingsController.dailyClaimReminderOn.value) {
    if (await reminder.areNotificationsEnabled()) {
      await reminder.showCatchUpReminder(profileController);
      await reminder.rescheduleFromProfile(profileController);
    } else {
      await settingsController.setDailyClaimReminderOn(false);
    }
  }

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  RecipeBook.initialize();

  runApp(
    Grimoji(
      profileController: profileController,
      settingsController: settingsController,
      dailyClaimReminder: reminder,
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await reminder.handleLaunchNotification();
  });
}
