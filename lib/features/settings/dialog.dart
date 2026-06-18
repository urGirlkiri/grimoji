import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/settings/widgets/icon_toggle.dart';
import 'package:grimoji/features/settings/widgets/volume_slider.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class SettingsDialog extends StatelessWidget {
  final int level;

  const SettingsDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final settings = context.readSettings;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
        rightButton: const CorkScrewCloseButton(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(
                context,
              ).copyWith(scrollbars: false),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 24.0,
                        ),
                        child: Column(
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
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
                                      ? 'music_on'
                                      : 'music_off',
                                  isActive:
                                      settings.musicOn.value &&
                                      settings.audioOn.value,
                                  onTap: settings.toggleMusicOn,
                                ),
                                IconToggle(
                                  fileName: settings.audioOn.value
                                      ? 'audio_on'
                                      : 'audio_off',
                                  isActive: settings.audioOn.value,
                                  onTap: settings.toggleAudioOn,
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            VolumeSlider(
                              label: "SFX Volume",
                              value: settings.sfxVolume.value,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
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
