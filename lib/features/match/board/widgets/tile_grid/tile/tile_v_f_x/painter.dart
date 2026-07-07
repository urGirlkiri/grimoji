import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grimoji/features/match/models/particle.dart';

class ParticleCanvPainter extends CustomPainter {
  final List<GridParticle> particles;
  final bool isCircular;

  ParticleCanvPainter(this.particles, {this.isCircular = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      if (p.life <= 0) continue;

      paint.color = p.color.withValues(alpha: p.alpha);

      final speed = sqrt(p.vx * p.vx + p.vy * p.vy);
      final angle = atan2(p.vy, p.vx);

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(angle);

      if (isCircular) {
        canvas.drawCircle(Offset.zero, p.size, paint);
      } else {
        final stretchMultiplier = (speed * 0.005).clamp(1.0, 3.5);

        final larvaLength = (p.size * 2) * stretchMultiplier;
        final larvaGirth = p.size * 1.5;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: larvaLength,
              height: larvaGirth,
            ),
            Radius.circular(larvaGirth / 2),
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ParticleCanvPainter oldDelegate) => true;
}
