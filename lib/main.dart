import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/features/profile/models/profile_data.dart';
import 'package:grimoji/features/profile/persistance/hive.dart';
import 'package:grimoji/grimoji.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';

import 'package:grimoji/features/level/models/level_data.dart';
import 'package:grimoji/features/settings/models/settings_data.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';


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

  await Hive.initFlutter();

  Hive.registerAdapter(SettingsDataAdapter());
  Hive.registerAdapter(LevelDataAdapter());
  Hive.registerAdapter(ProfileDataAdapter());

  await Hive.openBox<SettingsData>('settings');
  await Hive.openBox<LevelData>('level_data');
  await Hive.openBox<ProfileData>('player_profile');

  final persistence = HiveProfilePersistence();
  final profileController = ProfileController(persistence: persistence);

  await profileController.load();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  RecipeBook.initialize();

  runApp(Grimoji(profileController: profileController));
}
