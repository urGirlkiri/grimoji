class GoalManager {
  final int targetAmount;
  int _collectedAmount = 0;

  GoalManager({required this.targetAmount});

  int get collectedAmount => _collectedAmount;

  double get progress => (_collectedAmount / targetAmount).clamp(0.0, 1.0);

  bool get isComplete => progress >= 1.0;

  void add(int count) {
    _collectedAmount += count;
  }

  int calculateStars() {
    if (progress >= 1.0) return 3;
    if (progress >= 0.66) return 2;
    if (progress >= 0.33) return 1;
    return 0;
  }
}
