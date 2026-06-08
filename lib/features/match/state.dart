import 'package:flutter/foundation.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/match/board/utils/announcer.dart';

class GameState extends ChangeNotifier {
  final BoardAnnouncer announcer;

  bool isProcessing = false;
  bool hasTargetCombo = false;
  bool isShuffling = false;
  bool isPaused = false;
  bool isDisposed = false;
  bool isGameOver = false;

  int currentComboMultiplier = 0;
  double shuffleProgress = 1.0;
  
  int updateToken = 0; 

  GameState([AudioController? audio]) : announcer = BoardAnnouncer(audio ?? AudioController()) {
    announcer.gameState = this;
  }

  String? get activeAnnouncement => announcer.activeAnnouncement?.text;
  int get announcementToken => announcer.announcementToken;

  void setProcessing(bool value) {
    if (isProcessing != value) {
      isProcessing = value;
      _notify();
    }
  }

  void setHasTargetCombo(bool value) {
    if (hasTargetCombo != value) {
      hasTargetCombo = value;
      _notify();
    }
  }

  void setShuffling(bool value) {
    if (isShuffling != value) {
      isShuffling = value;
      _notify();
    }
  }

  void setPaused(bool value) {
    if (isPaused != value) {
      isPaused = value;
      _notify();
    }
  }

  void setGameOver() {
    if (!isGameOver) {
      isGameOver = true;
      _notify();
    }
  }

  void setComboMultiplier(int value) {
    if (currentComboMultiplier != value) {
      currentComboMultiplier = value;
      _notify();
    }
  }

  void incrementComboMultiplier() {
    currentComboMultiplier++;
    _notify();
  }

  void setShuffleProgress(double value) {
    if (shuffleProgress != value) {
      shuffleProgress = value;
      _notify();
    }
  }

  void updateUI() {
    updateToken++; 
    _notify();
  }

  void _notify() {
    if (!isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    isProcessing = false;
    super.dispose();
  }
}