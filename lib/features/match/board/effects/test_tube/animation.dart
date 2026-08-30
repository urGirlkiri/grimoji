import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_v_f_x/painter.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/match/models/particle.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:provider/provider.dart';

class TestTubeAnimation extends StatefulWidget {
  final double tileWidth;
  final double tileHeight;

  const TestTubeAnimation({
    super.key,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  State<TestTubeAnimation> createState() => _TestTubeAnimationState();
}

class _TestTubeAnimationState extends State<TestTubeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _impactCalled = false;
  final List<GridParticle> _particles = [];
  final Random _random = Random();
  double _lastT = 0.0;

  static const double _overshoot = 1.5;

  double get _tiltEnd =>
      tubeTiltDuration.inMilliseconds / tubeDropTotalDuration.inMilliseconds;

  double get _dropFallEnd =>
      (tubeTiltDuration + greenDropFallDuration).inMilliseconds /
      tubeDropTotalDuration.inMilliseconds;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: tubeDropTotalDuration,
    );

    _controller.addListener(_onTick);
    _controller.addStatusListener(_onStatus);
    _controller.forward();
  }

  void _onTick() {
    final t = _controller.value;
    final impactT = _dropFallEnd;

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
          color: _random.nextBool()
              ? dropColor.withValues(alpha: 5)
              : dropColor,
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

        final targetX = widget.tileWidth / 2;
        final targetY = widget.tileHeight / 2;

        final tiltProgress = (t / _tiltEnd).clamp(0.0, 1.0);
        final tiltAngle = tiltProgress * 0.3;

        final dropFallProgress = ((t - _tiltEnd) / (_dropFallEnd - _tiltEnd))
            .clamp(0.0, 1.0);

        final tubeSize = widget.tileWidth * 0.8;
        final tubeX = targetX - tubeSize;
        final tubeY = targetY + widget.tileHeight * 0.8 - tubeSize * 2.5;

        final tubeCenterX = tubeX + tubeSize / 2;
        final tubeCenterY = tubeY + tubeSize / 2;

        final mouthOffsetX = (tubeSize / 2) * sin(tiltAngle) + 20;
        final mouthOffsetY = -(tubeSize / 2) * cos(tiltAngle) + 12;
       
        final mouthX = tubeCenterX + mouthOffsetX;
        final mouthY = tubeCenterY + mouthOffsetY;

        final dropStartY = mouthY;
        final dropEndY = targetY;

        final greenDropY =
            dropStartY + (dropEndY - dropStartY) * dropFallProgress;

        final greenDropOpacity = dropFallProgress < 1.0 ? 1.0 : 0.0;

        final postImpact = ((t - _dropFallEnd) / (1.0 - _dropFallEnd)).clamp(
          0.0,
          1.0,
        );
        final tubeOpacity = 1.0 - postImpact;

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
              left: tubeX,
              top: tubeY,
              width: tubeSize,
              height: tubeSize,
              child: Transform.rotate(
                angle: tiltAngle,
                child: Opacity(
                  opacity: tubeOpacity.clamp(0.0, 1.0),
                  child: EmojiWidget.svg(
                    emoji: Emojis.testTube,
                    size: tubeSize,
                  ),
                ),
              ),
            ),

            if (t >= _tiltEnd && t < _dropFallEnd + 0.1)
              Positioned(
                left: mouthX - widget.tileWidth * 0.15,
                top: greenDropY - widget.tileWidth * 0.15,
                width: widget.tileWidth * 0.3,
                height: widget.tileWidth * 0.3,
                child: Opacity(
                  opacity: greenDropOpacity.clamp(0.0, 1.0),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      dropColor,
                      BlendMode.srcATop,
                    ),
                    child: EmojiWidget.svg(
                      emoji: Emojis.blood,
                      size: widget.tileWidth * 0.3,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
