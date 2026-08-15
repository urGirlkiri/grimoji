import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/board/effects/blood_drop/effect.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_v_f_x/painter.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/match/models/particle.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:provider/provider.dart';

class BloodDropAnimation extends StatefulWidget {
  final BloodDropEffect effect;
  final double tileWidth;
  final double tileHeight;

  const BloodDropAnimation({
    super.key,
    required this.effect,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  State<BloodDropAnimation> createState() => _BloodDropAnimationState();
}

class _BloodDropAnimationState extends State<BloodDropAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _impactCalled = false;
  final List<GridParticle> _particles = [];
  final Random _random = Random();
  double _lastT = 0.0;

  static const double _overshoot = 1.5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: bloodDropTotalDuration,
    );

    _controller.addListener(_onTick);
    _controller.addStatusListener(_onStatus);
    _controller.forward();
  }

  void _onTick() {
    final t = _controller.value;
    final impactT = _impactThreshold;

    if (!_impactCalled && t >= impactT) {
      _impactCalled = true;
      _lastT = t;
      _spawnParticles();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<LevelState>().markPowerupImpact();
      });
    }

    if (_particles.isNotEmpty) {
      final dt = t - _lastT;
      _lastT = t;
      for (final p in _particles) {
        p.update(dt, gravity: 300.0, drag: 0.92);
      }
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (mounted) context.read<LevelState>().completePowerupAnimation();
    }
  }

  double get _impactThreshold {
    return bloodDropDuration.inMilliseconds /
        bloodDropTotalDuration.inMilliseconds;
  }

  void _spawnParticles() {
    final centerX = widget.tileWidth * _overshoot;
    final centerY = widget.tileHeight * _overshoot;

    for (int i = 0; i < 35; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final velocity = 120.0 + _random.nextDouble() * 220.0;

      _particles.add(
        GridParticle(
          x: centerX,
          y: centerY,
          vx: cos(angle) * velocity,
          vy: sin(angle) * velocity - 80.0,
          size: 3.0 + _random.nextDouble() * 5.0,
          color: _random.nextBool() ? palette.crimson : palette.dusk,
          maxLife: 0.4 + _random.nextDouble() * 0.4,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.removeStatusListener(_onStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final impactT = _impactThreshold;

        final targetX = widget.tileWidth / 2;
        final targetY = widget.tileHeight / 2;

        final dropProgress = t < impactT
            ? Curves.easeIn.transform(t / impactT)
            : 1.0;

        final postImpact = (t - impactT).clamp(0.0, 1.0);

        final dropScale = t < impactT
            ? 0.6 + dropProgress * 0.4
            : (1.0 -
                      Curves.easeIn.transform(
                        (postImpact / 0.2).clamp(0.0, 1.0),
                      ))
                  .clamp(0.0, 1.0);

        final startY = -widget.tileHeight * 1.5;
        final dropSize = widget.tileWidth * dropScale;
        final dropX = (targetX - dropSize / 2);
        final dropY = startY + (targetY - startY) * dropProgress;

        final bloodOpacity = t < impactT ? 1.0 : 1.0 - postImpact / 0.2;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -widget.tileWidth,
              top: -widget.tileHeight,
              width: widget.tileWidth * _overshoot * 2,
              height: widget.tileHeight * _overshoot * 2,
              child: CustomPaint(
                size: Size(
                  widget.tileWidth * _overshoot * 2,
                  widget.tileHeight * _overshoot * 2,
                ),
                painter: ParticleCanvPainter(_particles, isCircular: false),
              ),
            ),
            Positioned(
              left: dropX,
              top: dropY - dropSize / 2,
              width: dropSize,
              height: dropSize,
              child: Opacity(
                opacity: bloodOpacity.clamp(0.0, 1.0),
                child: EmojiWidget.svg(emoji: Emojis.blood, size: dropSize),
              ),
            ),
          ],
        );
      },
    );
  }
}
