import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/level/managers/goal.dart';

class CrimsonFever {
  final GameLevel level;
  final GoalManager goalManager;
  int _score = 0;

  CrimsonFever({required this.level, required this.goalManager});

  void addExtraTargets(int count) {
    if (!goalManager.isComplete) return;
    _score += count * level.extraTargetWeight;
  }

  void addClearedTiles(int count) {
    if (!goalManager.isComplete) return;
    _score += count * level.tileClearWeight;
  }

  void addIntrusiveDestroyed(int count) {
    if (!goalManager.isComplete) return;
    _score += count * level.intrusiveWeight;
  }

  void addShapeMerges(int count) {
    if (!goalManager.isComplete) return;
    _score += count * level.shapeMergeWeight;
  }

  void addGhostDiveThreats(int count) {
    if (!goalManager.isComplete) return;
    _score += count * level.ghostDiveWeight;
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
