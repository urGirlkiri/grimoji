import 'package:flutter/material.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/features/settings/controller.dart';
import 'package:provider/provider.dart';

extension ContextData on BuildContext {
  ThemeData get theme => Theme.of(this);
  Palette get palette => read<Palette>();

  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isLargeScreen => screenWidth > 600;
  double get globalScale => isLargeScreen ? 1.5 : 1.0;

  ProfileController get readProfile => read<ProfileController>();
  ProfileController get watchProfile => watch<ProfileController>();

  SettingsController get readSettings => read<SettingsController>();
  SettingsController get watchSettings => watch<SettingsController>();

  AudioController get readAudio => read<AudioController>();
  AudioController get watchAudio => watch<AudioController>();
}
