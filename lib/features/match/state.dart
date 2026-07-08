import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  bool isProcessing = false;
  bool hasTargetCombo = false;
  bool isShuffling = false;
  bool isPaused = false;
  bool isDisposed = false;
  bool isGameOver = false;

  bool isFeverTime = false;
  bool isFeverComplete = false;
  int feverBombCount = 0;
  int remainingFeverBombs = 0;
  int feverTimer = 0;

  bool hintsEnabled = false;

  int currentComboMultiplier = 0;
  int tilesCleared = 0;
  bool hasLegendaryEmoji = false;
  double shuffleProgress = 1.0;

  int updateToken = 0;

  GameState();

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

  void addTilesCleared(int count) {
    tilesCleared += count;
    _notify();
  }

  void resetTilesCleared() {
    tilesCleared = 0;
    _notify();
  }

  void setLegendaryEmoji(bool value) {
    if (hasLegendaryEmoji != value) {
      hasLegendaryEmoji = value;
      _notify();
    }
  }

  void setShuffleProgress(double value) {
    if (shuffleProgress != value) {
      shuffleProgress = value;
      _notify();
    }
  }

  void setFeverTime(bool value) {
    if (isFeverTime != value) {
      isFeverTime = value;
      _notify();
    }
  }

  void setFeverComplete(bool value) {
    if (isFeverComplete != value) {
      isFeverComplete = value;
      _notify();
    }
  }

  void setFeverBombCount(int count) {
    if (feverBombCount != count) {
      feverBombCount = count;
      _notify();
    }
  }

  void setReFeverBombs(int remaining) {
    if (remainingFeverBombs != remaining) {
      remainingFeverBombs = remaining;
      _notify();
    }
  }

  void setFeverTimer(int timer) {
    if (feverTimer != timer) {
      feverTimer = timer;
      _notify();
    }
  }

  void decrementFeverTimer() {
    feverTimer--;
    _notify();
  }

  void setHintsEnabled(bool value) {
    if (hintsEnabled != value) {
      hintsEnabled = value;
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
