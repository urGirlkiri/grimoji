import 'package:hive/hive.dart';

part 'level_data.g.dart';

@HiveType(typeId: 0)
class LevelData {
  @HiveField(0)
  final int level;
  @HiveField(1)
  final int stars;
  @HiveField(2)
  final int? crimsonStars;

  const LevelData({
    required this.level,
    required this.stars,
    this.crimsonStars,
  });

  Map<String, dynamic> toJson() => {
    'level': level,
    'stars': stars,
    'crimsonStars': crimsonStars,
  };

  factory LevelData.fromJson(Map<String, dynamic> json) => LevelData(
    level: json['level'] as int,
    stars: json['stars'] as int,
    crimsonStars: json['crimsonStars'] as int?,
  );

  @override
  String toString() =>
      'LevelData(level: $level, stars: $stars, crimsonStars: $crimsonStars)';
}
