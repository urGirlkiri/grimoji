/// Model to store level completion data including stars
class LevelData {
  final int level;
  final int stars;

  const LevelData({
    required this.level,
    required this.stars,
  });

  Map<String, dynamic> toJson() => {
    'level': level,
    'stars': stars,
  };

  factory LevelData.fromJson(Map<String, dynamic> json) => LevelData(
    level: json['level'] as int,
    stars: json['stars'] as int,
  );

  @override
  String toString() => 'LevelData(level: $level, stars: $stars)';
}
