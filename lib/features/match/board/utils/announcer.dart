import 'dart:async';
import 'dart:math';
import 'package:logging/logging.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/voices/dialog.dart';
import 'package:grimoji/features/match/state.dart';

enum TurnEvent { merge, explosion, legendaryEmoji }

class BoardAnnouncer {
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
  late final GameState _state;

  Dialog? activeAnnouncement;
  int announcementToken = 0;

  final List<Dialog> _queue = [];
  bool _isLoopActive = false;
  Timer? _displayTimer;
  Timer? _cooldownTimer;
  DateTime? _lastAnnouncementTime;
  int _lastPriority = 0;

  BoardAnnouncer(this._audio);

  set gameState(GameState state) => _state = state;

  bool get isSpeaking => activeAnnouncement != null || _queue.isNotEmpty;
  bool get isInCooldown => _cooldownTimer?.isActive == true;

  void evaluateTurn({
    required Set<TurnEvent> events,
    required int combo,
    required int tilesCleared,
  }) {
    final isLegendary = events.contains(TurnEvent.legendaryEmoji);

    if (combo < 3 && tilesCleared < 10 && !isLegendary) return;

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
    _state.updateUI();

    _displayTimer?.cancel();
    _displayTimer = Timer(voiceTime, () {
      if (_queue.isEmpty && !_state.isDisposed) clear();
    });

    if (!_isLoopActive) _runPlaybackLoop();
  }

  Future<void> _runPlaybackLoop() async {
    _isLoopActive = true;

    while (_queue.isNotEmpty && !_state.isDisposed) {
      final nextVoice = _queue.removeAt(0);

      activeAnnouncement = nextVoice;
      announcementToken++;
      _lastAnnouncementTime = DateTime.now();
      _lastPriority = nextVoice.priority;

      startCooldown();
      _state.updateUI();
      _audio.playVoice(nextVoice);

      await Future.delayed(voiceTime);
    }

    if (!_state.isDisposed) clear();
    _isLoopActive = false;
  }

  void clear() {
    _displayTimer?.cancel();
    _queue.clear();
    activeAnnouncement = null;
    _state.updateUI();
  }

  void startCooldown() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(cooldownTime, () {});
  }

  void dispose() {
    _displayTimer?.cancel();
    _cooldownTimer?.cancel();
  }
}
