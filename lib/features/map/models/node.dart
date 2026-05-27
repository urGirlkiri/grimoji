class MapNode {
  final int level;
  final double x; 
  final double y; 

  MapNode({required this.level, required this.x, required this.y});

  factory MapNode.fromJson(Map<String, dynamic> json) {
    return MapNode(
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