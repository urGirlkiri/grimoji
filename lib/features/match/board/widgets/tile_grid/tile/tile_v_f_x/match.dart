import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/models/particle.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_v_f_x/painter.dart';

class TileMatch extends StatefulWidget {
  final double size;
  final Color color;

  const TileMatch({super.key, required this.size, required this.color});

  @override
  State<TileMatch> createState() => _TileMatchState();
}

class _TileMatchState extends State<TileMatch>
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
      duration: const Duration(milliseconds: 600),
    );

    _spawnPuff();
    _ticker.addListener(_onFrameTick);
    _ticker.forward();
  }

  void _spawnPuff() {
    final center = widget.size / 2;

    for (int i = 0; i < 20; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final velocity = 30.0 + _random.nextDouble() * 50.0;

      _particles.add(
        GridParticle(
          x: center + (cos(angle) * 10),
          y: center + (sin(angle) * 10),
          vx: cos(angle) * velocity,
          vy: (sin(angle) * velocity) - 20.0,
          size: 6.0 + _random.nextDouble() * 8.0,
          color: widget.color,
          maxLife: 0.4 + _random.nextDouble() * 0.2,
        ),
      );
    }
  }

  void _onFrameTick() {
    final current = _ticker.value * 0.6;
    final dt = current - _lastElapsed;
    _lastElapsed = current;

    for (final p in _particles) {
      p.update(dt, gravity: -80.0, drag: 0.92);
      p.size += 15.0 * dt;
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
        painter: ParticleCanvPainter(_particles, isCircular: true),
      ),
    );
  }
}
