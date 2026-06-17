import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/models/particle.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_v_f_x/painter.dart';
import 'package:grimoji/utils/context_data.dart';

class TileExplosion extends StatefulWidget {
  final double size;
  const TileExplosion({super.key, required this.size});

  @override
  State<TileExplosion> createState() => _TileExplosionState();
}

class _TileExplosionState extends State<TileExplosion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  final List<GridParticle> _particles = [];
  final Random _random = Random();
  double _lastElapsed = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _spawnExplosion();
    _ticker.addListener(_onFrameTick);
    _ticker.forward();
  }

  void _spawnExplosion() {
    final center = widget.size / 2;

    for (int i = 0; i < 45; i++) {
      final angle = _random.nextDouble() * 2 * pi;

      final velocity = 150.0 + _random.nextDouble() * 250.0;

      _particles.add(
        GridParticle(
          x: center,
          y: center,

          vx: cos(angle) * velocity,
          vy: sin(angle) * velocity - 100.0,

          size: 3.0 + _random.nextDouble() * 4.0,
          color: _random.nextBool()
              ? context.palette.dusk
              : context.palette.crimson,
          maxLife: 0.4 + _random.nextDouble() * 0.3,
        ),
      );
    }
  }

  void _onFrameTick() {
    final current = _ticker.value * 0.5;
    final dt = current - _lastElapsed;
    _lastElapsed = current;

    for (final p in _particles) {
      p.update(dt, gravity: 500.0, drag: 0.92);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.removeListener(_onFrameTick);
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: ParticleCanvPainter(_particles, isCircular: false),
      ),
    );
  }
}
