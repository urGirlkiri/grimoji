import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/board/effects/ufo/animation/u_f_o_beam.dart';
import 'package:grimoji/features/match/board/effects/ufo/effect.dart';
import 'package:grimoji/features/match/board/effects/ufo/models/beam.dart';
import 'package:grimoji/features/match/board/effects/ufo/models/beam_type.dart';
import 'package:grimoji/features/match/board/effects/ufo/models/keyframe.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:provider/provider.dart';

class UFOAnimation extends StatefulWidget {
  final UFOEffect effect;
  final double tileWidth;
  final double tileHeight;

  const UFOAnimation({
    super.key,
    required this.effect,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  State<UFOAnimation> createState() => _UFOAnimationState();
}

class _UFOAnimationState extends State<UFOAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Set<int> _beamImpactsCalled = {};
  final List<BeamAnimation> _activeBeams = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: ufoFlyDuration);
    _controller.addListener(_onTick);
    _controller.addStatusListener(_onStatus);
    _controller.forward();
  }

  void _onTick() {
    final t = _controller.value;
    final totalDuration = _controller.duration!.inMilliseconds;

    for (int i = 0; i < widget.effect.targets.length; i++) {
      final beamLandTime =
          widget.effect.beamDelays[i].inMilliseconds / totalDuration;

      if (!_beamImpactsCalled.contains(i) && t >= beamLandTime) {
        _beamImpactsCalled.add(i);
        _spawnBeamEffect(
          i,
          widget.effect.targets[i],
          widget.effect.beamTypes[i],
        );

        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) {
            context.read<LevelState>().impactUFOBeam(
              i,
              widget.effect.targets[i],
              widget.effect.beamTypes[i],
            );
          }
        });
      }
    }

    _activeBeams.removeWhere((beam) => beam.isComplete);
    for (final beam in _activeBeams) {
      beam.update(t);
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (mounted) context.read<LevelState>().completePowerupAnimation();
    }
  }

  void _spawnBeamEffect(
    int beamIndex,
    TileCoordinate target,
    UFOBeamType beamType,
  ) {
    final stepX = widget.tileWidth + tileSpacingGap;
    final stepY = widget.tileHeight + tileSpacingGap;

    final targetX = (target.col * stepX) + (widget.tileWidth / 2);
    final targetY = (target.row * stepY) + (widget.tileHeight / 2);
    final ufoY = -widget.tileHeight * 0.2;

    _activeBeams.add(
      BeamAnimation(
        targetX: targetX,
        targetY: targetY,
        ufoY: ufoY,
        beamType: beamType,
        startTime: _controller.value,
      ),
    );
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
        final ufoSize = widget.tileWidth * 0.8;
        final boardWidth = widget.tileWidth * BoardManager.cols;
        final stepX = widget.tileWidth + tileSpacingGap;
        final ufoY = -widget.tileHeight * 0.2;

        List<UfoKeyframe> keyframes = [UfoKeyframe(0.0, -ufoSize)];

        for (int i = 0; i < widget.effect.targets.length; i++) {
          final target = widget.effect.targets[i];
          final targetCenterX = (target.col * stepX) + (widget.tileWidth / 2);
          final ufoHoverX = targetCenterX - (ufoSize / 2);

          final centerT =
              widget.effect.beamDelays[i].inMilliseconds /
              _controller.duration!.inMilliseconds;

          keyframes.add(UfoKeyframe(max(0.0, centerT - 0.05), ufoHoverX));
          keyframes.add(UfoKeyframe(min(1.0, centerT + 0.10), ufoHoverX));
        }

        keyframes.add(UfoKeyframe(1.0, boardWidth + ufoSize));
        keyframes.sort((a, b) => a.t.compareTo(b.t));

        double ufoX = 0.0;
        for (int i = 0; i < keyframes.length - 1; i++) {
          if (t >= keyframes[i].t && t <= keyframes[i + 1].t) {
            final progress =
                (t - keyframes[i].t) / (keyframes[i + 1].t - keyframes[i].t);
            ufoX = ui.lerpDouble(
              keyframes[i].x,
              keyframes[i + 1].x,
              Curves.easeInOut.transform(progress),
            )!;
            break;
          }
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            ..._activeBeams.map(
              (beam) => UFOBeam(
                beam: beam,
                tileWidth: widget.tileWidth,
                tileHeight: widget.tileHeight,
              ),
            ),
            Positioned(
              left: ufoX,
              top: ufoY,
              width: ufoSize * 2,
              height: ufoSize * 2,
              child: Transform.rotate(
                angle: sin(t * pi * 2) * 0.1,
                child: SvgPicture.asset(
                  'assets/emojis/svg/ufo.svg',
                  width: ufoSize,
                  height: ufoSize,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
