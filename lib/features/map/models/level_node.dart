class LevelNde {
  final int level;
  final double x; 
  final double y; 

  LevelNde({required this.level, required this.x, required this.y});

  factory LevelNde.fromJson(Map<String, dynamic> json) {
    return LevelNde(
      level: json['level'] as int,
      x: json['x'].toDouble() as double,
      y: json['y'].toDouble() as double,
    );
  }

  Map<String, dynamic> toJson() => {
    'level': level,
    'x': double.parse(x.toStringAsFixed(3)), 
    'y': double.parse(y.toStringAsFixed(3)),
  };
}