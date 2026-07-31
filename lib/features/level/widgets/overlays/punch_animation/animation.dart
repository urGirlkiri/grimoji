import 'dart:math';
import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class FlyingPunchAnimation extends StatefulWidget {
  final Offset startPosition;
  final Offset targetPosition;
  final double tileSize;
  final VoidCallback onImpact;
  final VoidCallback onComplete;

  const FlyingPunchAnimation({
    super.key,
    required this.startPosition,
    required this.targetPosition,
    required this.tileSize,
    required this.onImpact,
    required this.onComplete,
  });

  @override
  State<FlyingPunchAnimation> createState() => _PunchFlyAnimationState();
}

class _PunchFlyAnimationState extends State<FlyingPunchAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _impactCalled = false;

  static const Duration _duration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);

    _controller.addListener(() {
      if (!_impactCalled && _controller.value >= 0.8) {
        _impactCalled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onImpact();
        });
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onComplete();
        });
      }
    });

    _controller.forward();
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
        final t = _controller.value;

        final dx = widget.targetPosition.dx - widget.startPosition.dx;
        final dy = widget.targetPosition.dy - widget.startPosition.dy;
        final travelAngle = atan2(dy, dx);

        const impactT = 0.8;
        const overshoot = 0.1;

        // Smooth out the start so it moves normally, then speed up near the target
        final toTargetT = t < impactT ? t / impactT : 1.0;
        final easedToTarget = Curves.easeInOut.transform(toTargetT);
        final travelProgress = t < impactT
            ? easedToTarget
            : 1.0 + (t - impactT) * overshoot;

        final x = widget.startPosition.dx + dx * travelProgress;
        final y = widget.startPosition.dy + dy * travelProgress;

        // Glove points toward the target and snaps forward a touch on impact
        final baseAngle = travelAngle + pi / 2;
        final impactSnap = t > impactT ? (t - impactT) * pi * 2 : 0.0;
        final angle = baseAngle + impactSnap;

        // Glove grows slightly as it closes in on the target, then shrinks after impact
        final closeIn = t < impactT
            ? Curves.easeIn.transform(t / impactT)
            : 0.0;
        final baseScale = t < impactT
            ? 1.0 + closeIn * 0.2
            : 1.2 - (t - impactT) * 1.0;
        final scaleX = baseScale * 0.9;
        final scaleY = baseScale * 1.1;
        final opacity = t < impactT ? 1.0 : 1.0 - (t - impactT) / 0.2;

        return Positioned(
          left: x - widget.tileSize / 2,
          top: y - widget.tileSize / 2,
          width: widget.tileSize,
          height: widget.tileSize,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: angle,
              child: Transform.scale(
                scaleX: scaleX,
                scaleY: scaleY,
                child: EmojiWidget.svg(
                  emoji: Emojis.boxingGlove,
                  size: widget.tileSize * 1.2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
