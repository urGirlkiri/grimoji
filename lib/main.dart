import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/features/profile/models/profile_data.dart';
import 'package:grimoji/features/profile/persistance/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:grimoji/router.dart';
import 'package:provider/provider.dart';

import 'package:grimoji/config/app/theme.dart';
import 'package:grimoji/utils/responsive.dart';
import 'package:grimoji/features/level/models/level_data.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/settings/persistence/settings_data.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';

import 'config/app/lifecycle.dart';
import 'features/audio/audio_controller.dart';
import 'features/settings/controller.dart';
import 'config/palette.dart';

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

  // Put game into full screen mode on mobile devices.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  RecipeBook.initialize();

  runApp(MyGame(profileController: profileController));
}

class MyGame extends StatelessWidget {
  final ProfileController profileController;
  const MyGame({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: profileController),
          Provider(create: (context) => SettingsController()),
          Provider(create: (context) => Palette()),
          ChangeNotifierProvider(create: (context) => LevelDataController()),
          // Set up audio.
          ProxyProvider2<
            AppLifecycleStateNotifier,
            SettingsController,
            AudioController
          >(
            create: (context) => AudioController(),
            update: (context, lifecycleNotifier, settings, audio) {
              audio!.attachDependencies(lifecycleNotifier, settings);
              return audio;
            },
            dispose: (context, audio) => audio.dispose(),
            // Ensures that music starts immediately.
            lazy: false,
          ),
        ],
        child: Builder(
          builder: (context) {
            final palette = context.watch<Palette>();
            final isLarge = context.isLargeScreen;

            return MaterialApp.router(
              title: 'Grimoji',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.buildTheme(palette, isLarge),
              routerConfig: router,
            );
          },
        ),
      ),
    );
  }
}
