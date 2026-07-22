import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/voices/dialog.dart';

enum TurnEvent { merge, explosion, legendaryEmoji, blackHole }

class BoardAnnouncer extends ChangeNotifier {
  static final _log = Logger('BoardAnnouncer');
  static const Duration voiceTime = Duration(milliseconds: 1500);
  static const Duration cooldownTime = Duration(seconds: 5);

  static const _alchemyVoices = [
    Dialog.alchemy,
    Dialog.alchemy,
    Dialog.wickedAlchemy,
    Dialog.diabolicalAlchemy,
    Dialog.sorcerousAlchemy,
    Dialog.magicalAlchemy,
    Dialog.masterfulAlchemy,
  ];
  static const _calamityVoices = [
    Dialog.alchemicalCalamity,
    Dialog.alchemicalCalamity,
    Dialog.wickedCalamity,
    Dialog.diabolicalCalamity,
    Dialog.sorcerousCalamity,
    Dialog.magicalCalamity,
    Dialog.magicalCalamity,
  ];

  final AudioController _audio;
  bool _isDisposed = false;

  Dialog? activeAnnouncement;
  int announcementToken = 0;

  final List<Dialog> _queue = [];
  bool _isLoopActive = false;
  Timer? _cooldownTimer;
  DateTime? _lastAnnouncementTime;
  int _lastPriority = 0;

  BoardAnnouncer(this._audio);

  bool get isSpeaking => activeAnnouncement != null || _queue.isNotEmpty;
  bool get isInCooldown => _cooldownTimer?.isActive == true;

  void evaluateTurn({
    required Set<TurnEvent> events,
    required int combo,
    required int tilesCleared,
  }) {
    final isLegendary = events.contains(TurnEvent.legendaryEmoji);
    final isBlackHole = events.contains(TurnEvent.blackHole);

    if (combo < 3 && tilesCleared < 10 && !isLegendary && !isBlackHole) return;

    int tileHype = tilesCleared >= 18
        ? 5
        : tilesCleared >= 15
        ? 4
        : tilesCleared >= 12
        ? 2
        : tilesCleared >= 10
        ? 1
        : 0;

    int hypeScore = max(combo, tileHype).clamp(1, 6);

    Dialog selectedVoice = isLegendary
        ? Dialog.catastrophicMasterpiece
        : isBlackHole
        ? Dialog.masterfulAlchemy
        : events.contains(TurnEvent.explosion)
        ? _calamityVoices[hypeScore]
        : _alchemyVoices[hypeScore];

    _queueAnnouncement(selectedVoice);
  }

  void _queueAnnouncement(Dialog voice) {
    if (isInCooldown && _lastAnnouncementTime != null) {
      bool canEscalate =
          DateTime.now().difference(_lastAnnouncementTime!).inSeconds < 2 &&
          voice.priority > _lastPriority;
      if (!canEscalate) return;
      _log.info(
        'Escalation override: Interrupting cooldown for higher priority!',
      );
    }

    if (_queue.contains(voice)) return;

    _queue.add(voice);
    notifyListeners();

    if (!_isLoopActive) _runPlaybackLoop();
  }

  Future<void> _runPlaybackLoop() async {
    _isLoopActive = true;

    while (_queue.isNotEmpty && !_isDisposed) {
      final nextVoice = _queue.removeAt(0);

      activeAnnouncement = nextVoice;
      announcementToken++;
      _lastAnnouncementTime = DateTime.now();
      _lastPriority = nextVoice.priority;

      startCooldown();
      notifyListeners();
      _audio.playVoice(nextVoice);

      await Future.delayed(voiceTime);
    }

    if (!_isDisposed) clear();
    _isLoopActive = false;
  }

  void clear() {
    _queue.clear();
    activeAnnouncement = null;
    notifyListeners();
  }

  void startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(cooldownTime, () {});
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cooldownTimer?.cancel();
    super.dispose();
  }
}
