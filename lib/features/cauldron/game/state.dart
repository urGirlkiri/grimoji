import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';

class CauldronState extends ChangeNotifier {
  bool isGameOver = false;
  int score = 0;
  GameEmoji nextEmoji;

  CauldronState({GameEmoji? nextEmoji}) : nextEmoji = nextEmoji ?? Emojis.heart;

  void setGameOver() {
    if (!isGameOver) {
      isGameOver = true;
      notifyListeners();
    }
  }

  void addScore(int points) {
    score += points;
    notifyListeners();
  }

  void setNextEmoji(GameEmoji emoji) {
    nextEmoji = emoji;
    notifyListeners();
  }

  void reset() {
    isGameOver = false;
    score = 0;
    notifyListeners();
  }
}
