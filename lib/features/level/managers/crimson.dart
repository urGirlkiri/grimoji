import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/level/managers/goal.dart';

class CrimsonFever {
  final GameLevel level;
  final GoalManager goalManager;
  int _score = 0;

  CrimsonFever({required this.level, required this.goalManager});

  bool get _canEarn => goalManager.isComplete;

  void addScore(int points) {
    if (!_canEarn) return;
    _score += points;
  }

  int get target => level.crimsonStarTarget;
  int get score => _score;

  double get progress {
    if (target <= 0) return 1.0;
    return (_score / target).clamp(0.0, 1.0);
  }

  int get stars {
    if (_score >= target) return 3;
    if (_score >= target * 0.7) return 2;
    if (_score >= target * 0.5) return 1;
    return 0;
  }
}
