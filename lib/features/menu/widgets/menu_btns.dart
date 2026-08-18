import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/audio/sounds/sfx.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:grimoji/widgets/responsive_screen.dart';

class MenuBtns extends StatefulWidget {
  static const _gap = SizedBox(height: 10);

  const MenuBtns({super.key});

  @override
  State<MenuBtns> createState() => _MenuBtnsState();
}

class _MenuBtnsState extends State<MenuBtns> {
  @override
  void initState() {
    super.initState();
    context.readAudio.playMenuMusic();
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = context.watchSettings;
    final audioController = context.readAudio;

    return ResponsiveScreen(
      squarishMainArea: const SizedBox.shrink(),
      rectangularMenuArea: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          PillButton(
            text: 'Play',
            color: palette.twilight,
            textColor: palette.mist,
            fullWidth: false,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            borderRadius: 20,
            borderColor: palette.magicCyan.withValues(alpha: .2),
            borderWidth: 3,
            onTap: () {
              audioController.playSfx(Sfx.buttonTap);
              GoRouter.of(context).goNamed(Routes.map);
            },
          ),
          MenuBtns._gap,
          PillButton(
            text: 'Trailer',
            color: palette.twilight,
            textColor: palette.mist,
            fullWidth: false,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            borderRadius: 20,
            borderColor: palette.magicCyan.withValues(alpha: .2),
            borderWidth: 3,
            onTap: () {
              audioController.playSfx(Sfx.buttonTap);
              GoRouter.of(context).goNamed(Routes.trailer);
            },
          ),
          MenuBtns._gap,
          PillButton(
            text: 'Settings',
            color: palette.twilight,
            textColor: palette.mist,
            fullWidth: false,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            borderRadius: 20,
            borderColor: palette.magicCyan.withValues(alpha: .2),
            borderWidth: 3,
            onTap: () {
              audioController.playSfx(Sfx.buttonTap);
              GoRouter.of(context).pushNamed(Routes.settings);
            },
          ),
          MenuBtns._gap,
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
          MenuBtns._gap,
        ],
      ),
    );
  }
}
