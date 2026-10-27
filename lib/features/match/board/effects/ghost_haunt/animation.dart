import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grimoji/features/alchemy/behaviors/dive.dart';
import 'package:grimoji/features/match/board/effects/ghost_dive/effect.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class GhostHaunter extends StatefulWidget {
  final GhostDiveEffect effect;
  final double tileWidth;
  final double tileHeight;

  const GhostHaunter({
    super.key,
    required this.effect,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  State<GhostHaunter> createState() => _GhostHaunterState();
}

class _GhostHaunterState extends State<GhostHaunter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _position;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final int _legs;

  @override
  void initState() {
    super.initState();

    final stepX = widget.tileWidth + tileSpacingGap;
    final stepY = widget.tileHeight + tileSpacingGap;

    final effect = widget.effect;
    final waypoints = effect.wanderPath.isNotEmpty
        ? effect.wanderPath
        : [effect.target];
    _legs = waypoints.length;

    final items = <TweenSequenceItem<Offset>>[];
    var previous = Offset.zero;
    for (final waypoint in waypoints) {
      final next = Offset(
        (waypoint.col - effect.origin.col) * stepX,
        (waypoint.row - effect.origin.row) * stepY,
      );
      items.add(
        TweenSequenceItem(
          tween: Tween<Offset>(begin: previous, end: next)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 1,
        ),
      );
      previous = next;
    }

    _controller = AnimationController(
      vsync: this,
      duration: ghostHauntDuration,
    )..forward();

    _position = TweenSequence<Offset>(items).animate(_controller);

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0.85), weight: 50),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
    ]).animate(_controller);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 50),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final sway = 0.18 * sin(_controller.value * pi * 2 * _legs);
        return Transform.translate(
          offset: _position.value,
          child: Opacity(
            opacity: _opacity.value.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: sway,
              child: Transform.scale(
                scale: _scale.value.clamp(0.0, 2.0),
                child: EmojiWidget.lottie(
                  emoji: DiveBehavior.emoji,
                  size: widget.tileWidth * ghostScaleFactor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
