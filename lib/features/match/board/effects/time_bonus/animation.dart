import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/features/match/board/effects/time_bonus/effect.dart';
import 'package:grimoji/features/match/models/particle.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_v_f_x/painter.dart';

class TimeBonusAnimation extends StatefulWidget {
  final TimeBonusEffect effect;

  const TimeBonusAnimation({super.key, required this.effect});

  @override
  State<TimeBonusAnimation> createState() => TimeBonusAnimationState();
}

class TimeBonusAnimationState extends State<TimeBonusAnimation> {
  final List<GridParticle> _particles = [];
  final Random _random = Random();
  double _lastT = 0.0;
  bool _particlesSpawned = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_particlesSpawned) {
      _spawnParticles();
      _particlesSpawned = true;
    }
  }

  void _spawnParticles() {
    for (int i = 0; i < 30; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final velocity = 100.0 + _random.nextDouble() * 200.0;

      _particles.add(
        GridParticle(
          x: 15,
          y: -25,
          vx: cos(angle) * velocity,
          vy: sin(angle) * velocity - 50.0,
          size: 3.0 + _random.nextDouble() * 5.0,
          color: _random.nextBool()
              ? palette.midnight
              : palette.dusk,
          maxLife: 0.5 + _random.nextDouble() * 0.4,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.effect.position.dx - 50,
      top: widget.effect.position.dy - 50,
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [

            IgnorePointer(
              child:
                  Text(
                        '+${widget.effect.amount}',
                        style: TextStyle(
                          color: palette.trueWhite,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      .animate()
                      .moveY(
                        begin: 0,
                        end: -50,
                        duration: 1000.ms,
                        curve: Curves.easeOut,
                      )
                      .fadeOut(duration: 1000.ms, curve: Curves.easeOut),
            ),
            const SizedBox(width: 100, height: 100).animate().custom(
              duration: 1000.ms,
              builder: (context, value, child) {
                final dt = value - _lastT;
                _lastT = value;

                for (final p in _particles) {
                  p.update(dt, gravity: 300.0, drag: 0.9);
                }

                return CustomPaint(
                  painter: ParticleCanvPainter(_particles, isCircular: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
