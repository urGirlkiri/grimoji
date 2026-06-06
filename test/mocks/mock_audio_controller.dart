import 'package:grimoji/app/lifecycle.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/voices/dialog.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/settings/controller.dart';

class MockAudioController implements AudioController {
  int playVoiceCallCount = 0;
  List<Dialog> playedVoices = [];
  bool disposeCalled = false;
  
  @override
  void playVoice(Dialog type) {
    playVoiceCallCount++;
    playedVoices.add(type);
  }
  
  @override
  void playSfx(SfxType type) {
  }
  
  @override
  void dispose() {
    disposeCalled = true;
  }
  
  @override
  void attachDependencies(
    AppLifecycleStateNotifier lifecycleNotifier,
    SettingsController settingsController,
  ) {
  }
  
  @override
  void playMenuMusic() {
  }
  
  @override
  void playLevelMusic() {
  }
}