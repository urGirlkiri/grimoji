import 'package:flutter/material.dart';
import 'package:grimoji/app/lifecycle.dart';
import 'package:grimoji/app/theme/index.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/router/index.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/features/settings/controller.dart';
import 'package:grimoji/services/notifications/daily_claim.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class Grimoji extends StatelessWidget {
  final ProfileController profileController;
  final SettingsController settingsController;
  final DailyClaimReminder dailyClaimReminder;

  const Grimoji({
    super.key,
    required this.profileController,
    required this.settingsController,
    required this.dailyClaimReminder,
  });

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      onResume: profileController.checkCauldronRegen,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: profileController),
          Provider.value(value: settingsController),
          Provider.value(value: dailyClaimReminder),
          ChangeNotifierProvider(create: (context) => LevelDataController()),
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
            lazy: false,
          ),
        ],
        child: Builder(
          builder: (context) {
            final scale = context.globalScale;

            return MaterialApp.router(
              title: 'Grimoji',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.buildTheme(palette, scale),
              routerConfig: router,
              builder: (context, child) => child ?? const SizedBox.shrink(),
            );
          },
        ),
      ),
    );
  }
}
