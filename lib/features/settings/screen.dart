import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/settings/dialogs/reset.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';
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

  void _showReminderStatus(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: context.palette.crimson,
        content: Center(
          child: Text(message, style: context.theme.textTheme.bodyLarge),
        ),
      ),
    );
  }

  Future<void> _toggleDailyClaimReminder(BuildContext context) async {
    final settings = context.readSettings;
    final reminder = context.readDailyClaimReminder;

    if (settings.dailyClaimReminderOn.value) {
      await settings.setDailyClaimReminderOn(false);
      await reminder.cancelReminder();
      return;
    }

    final granted = await reminder.requestPermission();
    final enabled = granted && await reminder.areNotificationsEnabled();
    if (!enabled) {
      if (context.mounted) {
        _showReminderStatus(
          context,
          'Enable notifications in your device settings to use reminders.',
        );
      }
      return;
    }

    if (!context.mounted) return;
    final profile = context.readProfile;
    await settings.setDailyClaimReminderOn(true);
    await reminder.rescheduleFromProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watchSettings;
    final palette = context.palette;
    final isLarge = context.isLargeScreen;
    final scale = context.globalScale;

    return Scaffold(
      backgroundColor: palette.voidBlack,
      body: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/emo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: ScrollDialog(
              rightButton: const CorkScrewCloseButton(),
              child: Padding(
                padding: EdgeInsets.only(
                  left: isLarge ? 60.0 : 40.0,
                  right: isLarge ? 60.0 : 40.0,
                  top: 50.0,
                  bottom: 170.0,
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
                        settings.dailyClaimReminderOn,
                      ]),
                      builder: (context, child) {
                        return Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            IconToggle(
                              fileName: 'dice',
                              isActive: settings.dailyClaimReminderOn.value,
                              onTap: () => _toggleDailyClaimReminder(context),
                              label: 'Reminder',
                            ),
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
                      listenable: settings.emojiAnimations,
                      builder: (context, child) {
                        return Column(
                          children: [
                            Text(
                              '${settings.emojiAnimations.value ? 'Disable' : 'Enable'} Emoji Animations',
                              textAlign: TextAlign.center,
                              style: context.theme.textTheme.bodyLarge
                                  ?.copyWith(color: palette.midnight),
                            ),
                            SizedBox(height: 12 * scale),
                            AnimatedButton(
                              onTap: settings.toggleEmojiAnimations,
                              child: Opacity(
                                opacity: settings.emojiAnimations.value
                                    ? 1.0
                                    : 0.4,
                                child: settings.emojiAnimations.value
                                    ? EmojiWidget.lottie(
                                        emoji: Emojis.robot,
                                        size: 64 * scale,
                                      )
                                    : EmojiWidget.svg(
                                        emoji: Emojis.robot,
                                        size: 64 * scale,
                                      ),
                              ),
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
                        settings.emojiAnimations,
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
            ),
          ),
        ],
      ),
    );
  }
}
