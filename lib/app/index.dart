import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grimoji/app/lifecycle.dart';
import 'package:grimoji/app/theme.dart';
import 'package:grimoji/app/palette.dart';
import 'package:grimoji/config/router/index.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/features/settings/controller.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';
import 'package:flutter_performance_optimizer/flutter_performance_optimizer.dart';

class Grimoji extends StatelessWidget {
  final ProfileController profileController;
  const Grimoji({super.key, required this.profileController});

  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: profileController),
          Provider(create: (context) => SettingsController()),
          Provider(create: (context) => Palette()),
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
            final palette = context.palette;
            final scale = context.globalScale;

            return MaterialApp.router(
              title: 'Grimoji',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.buildTheme(palette, scale),
              routerConfig: router,
              builder: (context, child) {
                return PerformanceOptimizer(
                  enabled: kDebugMode,         
                  showDashboard: kDebugMode,   
                  showHeatmap: false,        
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}