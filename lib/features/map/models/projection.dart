class Projection {
  final bool isVisible;
  final double x;
  final double y;
  final double scale;
  final double depth;

  final double opacity;

  Projection({
    required this.isVisible,
    required this.x,
    required this.y,
    required this.scale,
    required this.depth,
    this.opacity = 1.0,
  });
}
