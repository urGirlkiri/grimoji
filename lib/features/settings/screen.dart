import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/features/settings/dialogs/reset.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:provider/provider.dart';

import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/features/settings/widgets/icon_toggle.dart';
import 'package:grimoji/features/settings/widgets/volume_slider.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _resetProgress(BuildContext context) async {
    final palette = context.palette;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return const ResetDialog();
      },
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    await context.read<LevelDataController>().reset();
    if (!context.mounted) return;

    await context.read<ProfileController>().reset();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: palette.midnight,
        content: Center(
          child: Text(
            'Player progress has been reset.',
            style: context.theme.textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watchSettings;
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
                  'assets/images/scrolls/verticalWideLong.png',
                  fit: isLarge ? BoxFit.fill : BoxFit.fitWidth,
                  width: 677,
                  height: isLarge ? 677 : null,
                ),

                Positioned(
                  top: isLarge ? -1 : -10,
                  right: isLarge ? -1 : -1,
                  child: const CorkScrewCloseButton(),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
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
                                    ? 'music_on'
                                    : 'music_off',
                                isActive:
                                    settings.musicOn.value &&
                                    settings.audioOn.value,
                                onTap: settings.toggleMusicOn,
                                label: 'Music',
                              ),
                              IconToggle(
                                fileName: settings.audioOn.value
                                    ? 'audio_on'
                                    : 'audio_off',
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
                          settings.dailyClaimReminderOn,
                        ]),
                        builder: (context, child) {
                          return Column(
                            children: [
                              VolumeSlider(
                                label: "SFX Volume",
                                value: settings.sfxVolume.value,
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
                                onChanged:
                                    (settings.musicOn.value &&
                                        settings.audioOn.value)
                                    ? (val) => settings.setMusicVolume(val)
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Daily Claim Reminder',
                                      style: GoogleFonts.eagleLake(
                                        color: context.palette.midnight,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Switch(
                                      value:
                                          settings.dailyClaimReminderOn.value,
                                      onChanged: (_) async {
                                        settings.toggleDailyClaimReminderOn();
                                        final reminder =
                                            context.readDailyClaimReminder;
                                        final profile = context.readProfile;
                                        if (settings
                                            .dailyClaimReminderOn
                                            .value) {
                                          await reminder.requestPermission();
                                          await reminder.rescheduleFromProfile(
                                            profile,
                                          );
                                        } else {
                                          await reminder.cancelReminder();
                                        }
                                      },
                                      activeTrackColor: palette.mist,
                                      activeThumbColor: palette.midnight,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                      PillButton(
                        text: "Reset Progress",
                        enableAnimation: false,
                        color: palette.crimson,
                        onTap: () => _resetProgress(context),
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
