import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grimoji/app/palette.dart';
import 'package:grimoji/features/alchemy/behaviors/dive.dart';
import 'package:grimoji/features/match/board/models/ghost_dive.dart';
import 'package:grimoji/features/match/board/models/particle.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/tile/tile_v_f_x/painter.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class GhostDiver extends StatefulWidget {
  final GhostDiveEffect effect;
  final double tileWidth;
  final double tileHeight;

  const GhostDiver({
    super.key,
    required this.effect,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  State<GhostDiver> createState() => _GhostDiverState();
}

class _GhostDiverState extends State<GhostDiver>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _position;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;
  late final Animation<double> _rotation;
  late final Offset _endOffset;
  final List<GridParticle> _particles = [];
  final Random _random = Random();
  bool _hasBurst = false;

  @override
  void initState() {
    super.initState();

    final stepX = widget.tileWidth + tileSpacingGap;
    final stepY = widget.tileHeight + tileSpacingGap;

    final effect = widget.effect;
    final dCol = effect.target.col - effect.origin.col;
    final dRow = effect.target.row - effect.origin.row;

    const Offset startOffset = Offset.zero;
    _endOffset = Offset(dCol * stepX, dRow * stepY);

    final double arcHeight = max(stepX, stepY) * 0.4;
    final Offset midOffset = Offset(
      (startOffset.dx + _endOffset.dx) / 2,
      (startOffset.dy + _endOffset.dy) / 2 - arcHeight,
    );

    _controller = AnimationController(vsync: this, duration: ghostDiveDuration)
      ..forward();

    _position = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: startOffset,
          end: midOffset,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: midOffset,
          end: _endOffset,
        ).chain(CurveTween(curve: Curves.decelerate)),
        weight: 50,
      ),
      TweenSequenceItem(tween: ConstantTween<Offset>(_endOffset), weight: 10),
    ]).animate(_controller);

    final double travelAngle = atan2(dRow.toDouble(), dCol.toDouble());
    _rotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: travelAngle * 0.5,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: travelAngle * 0.5,
          end: travelAngle,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 90),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInExpo)),
        weight: 10,
      ),
    ]).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 90),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInExpo)),
        weight: 10,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.value >= 0.9 && !_hasBurst) {
          _hasBurst = true;
          _spawnBurst(_endOffset.dx, _endOffset.dy, palette);
        }

        for (final p in _particles) {
          p.update(0.016, gravity: 200.0, drag: 0.95);
        }
        _particles.removeWhere((p) => p.life <= 0);

        return Stack(
          children: [
            if (_particles.isNotEmpty)
              Positioned.fill(
                child: CustomPaint(
                  painter: ParticleCanvPainter(_particles, isCircular: true),
                ),
              ),
            Transform.translate(
              offset: _position.value,
              child: Opacity(
                opacity: _opacity.value.clamp(0.0, 1.0),
                child: Transform.rotate(
                  angle: _rotation.value,
                  child: Transform.scale(
                    scale: _scale.value.clamp(0.0, 2.0),
                    child: EmojiWidget.lottie(
                      path: DiveBehavior.emoji.lottie,
                      size: widget.tileWidth * ghostScaleFactor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _spawnBurst(double x, double y, Palette palette) {
    final List<Color> colors = [palette.mist, palette.crimson, palette.dusk];
    for (int i = 0; i < 50; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final velocity = 150.0 + _random.nextDouble() * 250.0;
      _particles.add(
        GridParticle(
          x: x,
          y: y,
          vx: cos(angle) * velocity,
          vy: sin(angle) * velocity - 80.0,
          size: 8.0 + _random.nextDouble() * 12.0,
          color: colors[_random.nextInt(colors.length)],
          maxLife: 0.4 + _random.nextDouble() * 0.3,
        ),
      );
    }
  }
}
