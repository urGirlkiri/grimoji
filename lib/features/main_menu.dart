import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';
import 'package:grimoji/widgets/neon_logo.dart';

import 'audio/sounds.dart';
import '../widgets/custom/pill_button.dart';
import '../widgets/responsive_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final settingsController = context.watchSettings;
    final audioController = context.watchAudio;

    return Scaffold(
      backgroundColor: palette.midnight,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/emo_2.png', fit: BoxFit.cover),
          ),
          ResponsiveScreen(
            squarishMainArea: LayoutBuilder(
              builder: (context, constraints) {
                final maxSize = constraints.maxWidth < constraints.maxHeight
                    ? constraints.maxWidth * 0.65
                    : constraints.maxHeight * 0.5;
                final imageSize = maxSize.clamp(100.0, 512.0);

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Image.asset(
                          'assets/icons/512x512.png',
                          fit: BoxFit.contain,
                          width: imageSize,
                          height: imageSize,
                        ),
                      ),
                      const SizedBox(height: 16),
                      NeonLogo(imageSize: imageSize),
                    ],
                  ),
                );
              },
            ),
            rectangularMenuArea: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PillButton(
                    text: 'Play',
                    color: palette.twilight,
                    textColor: palette.mist,
                    fullWidth: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    borderRadius: 20,
                    borderColor: palette.magicCyan.withValues(alpha: .2),
                    borderWidth: 3,
                    onTap: () {
                      audioController.playSfx(SfxType.buttonTap);
                      GoRouter.of(context).goNamed(Routes.map);
                    },
                  ),
                  _gap,
                  PillButton(
                    text: 'Settings',
                    color: palette.twilight,
                    textColor: palette.mist,
                    fullWidth: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    borderRadius: 20,
                    borderColor: palette.magicCyan.withValues(alpha: .2),
                    borderWidth: 3,
                    onTap: () {
                      audioController.playSfx(SfxType.buttonTap);
                      GoRouter.of(context).pushNamed(Routes.settings);
                    },
                  ),
                  _gap,
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ValueListenableBuilder<bool>(
                      valueListenable: settingsController.audioOn,
                      builder: (context, audioOn, child) {
                        return AppIcon(
                          fileName: audioOn ? 'sound_on' : 'sound_off',
                          onTap: settingsController.toggleAudioOn,
                          size: 24,
                        );
                      },
                    ),
                  ),
                  _gap,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _gap = SizedBox(height: 10);
}
