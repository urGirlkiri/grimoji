import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/audio/audio_controller.dart';
import 'package:grimoji/config/audio/sounds.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/settings/controller.dart';
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
        rightButton: GestureDetector(
          onTap: () {
            context.read<AudioController>().playSfx(SfxType.buttonTap);
            Navigator.of(context).pop();
          },
          child: Image.asset(
            'assets/icons/app/close.png',
            width: 60,
            height: 60,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Settings",
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
                  settings.sfxVolume,
                  settings.musicVolume,
                ]),
                builder: (context, child) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAppIconToggle(
                            settings.soundsOn.value
                                ? 'assets/icons/app/vibration_on.png'
                                : 'assets/icons/app/vibration_off.png',
                            palette,
                            isActive: settings.soundsOn.value && settings.audioOn.value,
                            onTap: () {
                              context.read<AudioController>().playSfx(
                                SfxType.buttonTap,
                              );
                              settings.toggleSoundsOn();
                            },
                          ),
                          _buildAppIconToggle(
                            settings.musicOn.value
                                ? 'assets/icons/app/sfx_on.png'
                                : 'assets/icons/app/sfx_off.png',
                            palette,
                            isActive: settings.musicOn.value && settings.audioOn.value,
                            onTap: () {
                              context.read<AudioController>().playSfx(
                                SfxType.buttonTap,
                              );
                              settings.toggleMusicOn();
                            },
                          ),
                          _buildAppIconToggle(
                            settings.audioOn.value
                                ? 'assets/icons/app/music_on.png'
                                : 'assets/icons/app/music_off.png',
                            palette,
                            isActive: settings.audioOn.value,
                            onTap: () {
                              context.read<AudioController>().playSfx(
                                SfxType.buttonTap,
                              );
                              settings.toggleAudioOn();
                            },
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      _buildVolumeSlider(
                        label: "SFX Volume",
                        value: settings.sfxVolume.value,
                        palette: palette,
                        onChanged: (settings.soundsOn.value && settings.audioOn.value) ? (val) {
                          settings.setSfxVolume(val);
                        } : null,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      _buildVolumeSlider(
                        label: "Music Volume",
                        value: settings.musicVolume.value,
                        palette: palette,
                        onChanged: (settings.musicOn.value && settings.audioOn.value) ? (val) {
                          settings.setMusicVolume(val);
                        } : null,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              const SizedBox(height: 32),

              const SizedBox(height: 40),

              // _buildPillButton(
              //   text: "Save progress",
              //   color: palette.twilight,
              //   palette: palette,
              //   onTap: () {
              //     context.read<AudioController>().playSfx(SfxType.buttonTap);
              //     // TODO: implement cloud saving
              //   },
              // ),
              const SizedBox(height: 16),

              _buildPillButton(
                text: "Quit level",
                color: palette.crimson,
                palette: palette,
                onTap: () {
                  context.read<AudioController>().playSfx(SfxType.buttonTap);
                  Navigator.of(context).pop();
                  GoRouter.of(context).go('/play/fail/$level');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppIconToggle(
    String imagePath,
    Palette palette, {
    bool isActive = true,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isActive ? 1.0 : 0.4,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          width: 80,
          height: 80,
        ),
      ),
    );
  }

  Widget _buildVolumeSlider({
    required String label,
    required double value,
    required ValueChanged<double>? onChanged,
    required Palette palette,
  }) {
    final bool isEnabled = onChanged != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
          child: Text(
            label,
            style: GoogleFonts.eagleLake(
              color: isEnabled ? palette.midnight : palette.slate,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: palette.mist,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: palette.slate, width: 2),
            boxShadow: [
              BoxShadow(
                color: palette.voidBlack.withValues(alpha: 0.2),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: isEnabled ? palette.midnight : palette.slate,
              inactiveTrackColor: palette.twilight.withValues(alpha: 0.3),
              thumbColor: isEnabled ? palette.trueWhite : palette.mist,
              overlayColor: isEnabled ? palette.midnight.withValues(alpha: 0.2) : Colors.transparent,
              trackHeight: 8.0,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 16.0),
            ),
            child: Slider(
              value: value,
              min: 0.0,
              max: 1.0,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillButton({
    required String text,
    required Color color,
    required Palette palette,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: palette.trueWhite, width: 2),
          boxShadow: [
            BoxShadow(
              color: palette.voidBlack.withValues(alpha: 0.4),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.eagleLake(
              fontSize: 22,
              color: palette.trueWhite,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: palette.voidBlack.withValues(alpha: 0.5),
                  offset: const Offset(1, 2),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
