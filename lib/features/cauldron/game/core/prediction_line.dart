import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';

const Palette palette = Palette();

class PredictionLine extends PositionComponent {
  Vector2? start;
  Vector2? end;

  @override
  void render(Canvas canvas) {
    if (start == null || end == null) return;

    final paint = Paint()
      ..color = palette.slate
      ..strokeWidth = 0.1
      ..strokeCap = StrokeCap.round;

    const double dashLength = 0.3;
    const double gapLength = 0.2;

    final direction = end! - start!;
    final totalLength = direction.length;

    if (totalLength <= 0) return;

    direction.normalize();

    double distance = 0;

    while (distance < totalLength) {
      final dashStart = start! + direction * distance;
      final dashEnd =
          start! + direction * (distance + dashLength).clamp(0, totalLength);

      canvas.drawLine(dashStart.toOffset(), dashEnd.toOffset(), paint);

      distance += dashLength + gapLength;
    }
  }

  void updateLine(Vector2? newStart, Vector2? newEnd) {
    start = newStart;
    end = newEnd;
  }
}
