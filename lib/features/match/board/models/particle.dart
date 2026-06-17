import 'package:flutter/material.dart';

class GridParticle {
  double x, y;
  double vx, vy;
  double size;
  double alpha;
  final Color color;
  final double maxLife;
  double life;

  GridParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.maxLife,
  }) : life = maxLife, alpha = 1.0;

  void update(double dt, {double gravity = 0.0, double drag = 1.0}) {
    life -= dt;
    vx *= drag;
    vy *= drag;
    vy += gravity * dt;
    x += vx * dt;
    y += vy * dt;
    alpha = (life / maxLife).clamp(0.0, 1.0);
  }
}