import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:provider/provider.dart';

import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/settings/controller.dart';
import 'package:grimoji/features/settings/widgets/icon_toggle.dart';
import 'package:grimoji/features/settings/widgets/volume_slider.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final palette = context.palette;
    final isLarge = context.isLargeScreen;

    return Scaffold(
      backgroundColor: palette.voidBlack,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/emo.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 677,
            height: isLarge ? 677 : null,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/scroll.png',
                  fit: isLarge ? BoxFit.fill : BoxFit.fitWidth,
                  width: 677,
                  height: isLarge ? 677 : null,
                ),

                Positioned(
                  top: isLarge ? -1 : -10,
                  right: isLarge ? -1 : -1,
                  child: CorkScrewCloseButton(),
                ),

                Padding(
                  padding:  EdgeInsets.symmetric(
                    horizontal: isLarge ? 60.0 : 40.0,
                    vertical: 50.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Settings',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.eagleLake(
                          color: palette.midnight,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                  
                      ListenableBuilder(
                        listenable: Listenable.merge([
                          settings.audioOn,
                          settings.soundsOn,
                          settings.musicOn,
                        ]),
                        builder: (context, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconToggle(
                                fileName: settings.soundsOn.value
                                    ? 'vibration_on'
                                    : 'vibration_off',
                                isActive:
                                    settings.soundsOn.value &&
                                    settings.audioOn.value,
                                onTap: settings.toggleSoundsOn,
                                label: 'SFX',
                              ),
                              IconToggle(
                                fileName: settings.musicOn.value
                                    ? 'sfx_on'
                                    : 'sfx_off',
                                isActive:
                                    settings.musicOn.value &&
                                    settings.audioOn.value,
                                onTap: settings.toggleMusicOn,
                                label: 'Music',
                              ),
                              IconToggle(
                                fileName: settings.audioOn.value
                                    ? 'music_on'
                                    : 'music_off',
                                isActive: settings.audioOn.value,
                                onTap: settings.toggleAudioOn,
                                label: 'Audio',
                              ),
                            ],
                          );
                        },
                      ),
                  
                      const SizedBox(height: 24),
                  
                      ListenableBuilder(
                        listenable: Listenable.merge([
                          settings.soundsOn,
                          settings.musicOn,
                          settings.audioOn,
                          settings.sfxVolume,
                          settings.musicVolume,
                        ]),
                        builder: (context, child) {
                          return Column(
                            children: [
                              VolumeSlider(
                                label: "SFX Volume",
                                value: settings.sfxVolume.value,
                                palette: palette,
                                onChanged:
                                    (settings.soundsOn.value &&
                                        settings.audioOn.value)
                                    ? (val) => settings.setSfxVolume(val)
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
                                    ? (val) => settings.setMusicVolume(val)
                                    : null,
                              ),
                            ],
                          );
                        },
                      ),
                  
                      const SizedBox(height: 24),
                  
                      PillButton(
                        text: "Reset Progress",
                        color: palette.crimson,
                        onTap: () async {
                          await context.read<LevelDataController>().reset();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: palette.midnight,
                              content: Center(
                                child: Text(
                                  'Player progress has been reset.',
                                  style: GoogleFonts.eagleLake(
                                    color: palette.trueWhite,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
