import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/settings/controller.dart';
import 'package:grimoji/features/settings/widgets/icon_toggle.dart';
import 'package:grimoji/features/settings/widgets/volume_slider.dart';
import 'package:grimoji/widgets/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/pill_button.dart';
import 'package:grimoji/widgets/scroll_dialog.dart';
import 'package:provider/provider.dart';

class SettingsDialog extends StatelessWidget {
  final int level;

  const SettingsDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final settings = context.read<SettingsController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScrollDialog(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
        rightButton:  CorkScrewCloseButton(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Settings",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.eagleLake(
                      color: palette.midnight,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ListenableBuilder(
                    listenable: Listenable.merge([
                      settings.audioOn,
                      settings.soundsOn,
                      settings.musicOn,
                      settings.sfxVolume,
                      settings.musicVolume,
                    ]),
                    builder: (context, child) {
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 16,
                              runSpacing: 12,
                              children: [
                                IconToggle(
                                  fileName: settings.soundsOn.value
                                      ? 'vibration_on'
                                      : 'vibration_off',
                                  isActive:
                                      settings.soundsOn.value &&
                                      settings.audioOn.value,
                                  onTap: settings.toggleSoundsOn,
                                ),
                                IconToggle(
                                  fileName: settings.musicOn.value
                                      ? 'sfx_on'
                                      : 'sfx_off',
                                  isActive:
                                      settings.musicOn.value &&
                                      settings.audioOn.value,
                                  onTap: settings.toggleMusicOn,
                                ),
                                IconToggle(
                                  fileName: settings.audioOn.value
                                      ? 'music_on'
                                      : 'music_off',
                                  isActive: settings.audioOn.value,
                                  onTap: settings.toggleAudioOn,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            VolumeSlider(
                              label: "SFX Volume",
                              value: settings.sfxVolume.value,
                              palette: palette,
                              onChanged:
                                  (settings.soundsOn.value &&
                                      settings.audioOn.value)
                                  ? (val) {
                                      settings.setSfxVolume(val);
                                    }
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            VolumeSlider(
                              label: "Music Volume",
                              value: settings.musicVolume.value,
                              palette: palette,
                              onChanged:
                                  (settings.musicOn.value &&
                                      settings.audioOn.value)
                                  ? (val) {
                                      settings.setMusicVolume(val);
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: PillButton(
                      text: "Quit level",
                      color: palette.crimson,
                      onTap: () {
                        Navigator.of(context).pop();
                        GoRouter.of(context).goNamed(
                          Routes.levelFail,
                          pathParameters: {'level': level.toString()},
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
