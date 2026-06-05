import 'dart:async';
import 'package:logging/logging.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/voices/dialog.dart';
import 'package:grimoji/features/game/state.dart';

class BoardAnnouncer {
  static final _log = Logger('BoardAnnouncer');
  static const Duration voiceTime = Duration(milliseconds: 1500);

  final AudioController _audio;
  late final GameState _state;

  Dialog? activeAnnouncement;
  int announcementToken = 0;

  final List<Dialog> _queue = [];
  bool _isLoopActive = false;
  Timer? _displayTimer;

  BoardAnnouncer(this._audio);

  set gameState(GameState state) => _state = state;

  bool get isSpeaking => activeAnnouncement != null || _queue.isNotEmpty;

  void announceCombo(int comboMultiplier, {bool isCalamity = false}) {
    final validVoices = Dialog.values.where((v) => 
        v.isCalamity == isCalamity && v.minCombo <= comboMultiplier)
      .toList()
      ..sort((a, b) => b.minCombo.compareTo(a.minCombo));
    
    final selectedVoice = validVoices.first;

    _log.info('Announcing: "${selectedVoice.text}" (priority: ${selectedVoice.priority})');

    if (activeAnnouncement != null) {
      if (selectedVoice.priority <= activeAnnouncement!.priority && activeAnnouncement!.priority >= 3) {
        return; 
      }
    }

    if (_queue.contains(selectedVoice)) return;

    _queue.add(selectedVoice);
    
    _state.updateUI();
    _extendActiveDisplay();

    if (!_isLoopActive) {
      _runPlaybackLoop();
    }
  }

  Future<void> _runPlaybackLoop() async {
    _log.info('Starting announcement playback loop');
    _isLoopActive = true;

    while (_queue.isNotEmpty && !_state.isDisposed) {
      final nextVoice = _queue.removeAt(0);

      _log.info('Playing announcement: "${nextVoice.text}"');
      activeAnnouncement = nextVoice;
      announcementToken++;
      _state.updateUI();

      _log.info('Triggering voice for type: $nextVoice');
      _audio.playVoice(nextVoice);

      await Future.delayed(voiceTime);
    }

    _log.info('Announcement loop finished');
    if (!_state.isDisposed) {
      clear();
    }
    _isLoopActive = false;
  }

  void _extendActiveDisplay() {
    _log.info('Extending display timer');
    _displayTimer?.cancel();

    _displayTimer = Timer(voiceTime, () {
      if (_queue.isEmpty && !_state.isDisposed) {
        clear();
      }
    });
  }

  void clear() {
    _log.info('Clearing announcements');
    _displayTimer?.cancel();
    _queue.clear();
    activeAnnouncement = null;
    _state.updateUI();
  }
}