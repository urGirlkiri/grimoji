import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/audio/sounds/sfx.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';

import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:grimoji/widgets/responsive_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  static const _gap = SizedBox(height: 10);
  static const _xPaddle = 40.0;
  @override
  void initState() {
    super.initState();
    context.readAudio.playMenuMusic();
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watchSettings;
    final audioController = context.watchAudio;

    return Scaffold(
      backgroundColor: palette.midnight,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/room.jpeg', fit: BoxFit.cover),
          ),
          Positioned(
            top: 32,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _xPaddle),
              child: Center(
                child: Image.asset(
                  'assets/images/text_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          ResponsiveScreen(
            squarishMainArea: const SizedBox.shrink(),
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
                      audioController.playSfx(Sfx.buttonTap);
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
                      audioController.playSfx(Sfx.buttonTap);
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
}
