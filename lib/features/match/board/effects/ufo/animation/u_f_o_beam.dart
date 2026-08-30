import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/effects/ufo/models/beam.dart';
import 'package:grimoji/features/match/board/effects/ufo/models/beam_type.dart';
import 'package:grimoji/features/match/constants.dart';

class UFOBeam extends StatelessWidget {
  const UFOBeam({
    super.key,
    required this.beam,
    required this.tileWidth,
    required this.tileHeight,
  });

  final BeamAnimation beam;
  final double tileWidth;
  final double tileHeight;

  @override
  Widget build(BuildContext context) {
    final beamColor = beam.beamType == UFOBeamType.abduct
        ? abductBeamColor
        : explosiveBeamColor;

    final beamProgress = beam.progress;
    final beamHeight = tileHeight * 2;

    return Positioned(
      left: beam.targetX - tileWidth * 0.1,
      top: -tileHeight * 0.5 + (beamHeight * beamProgress),
      width: tileWidth * 0.2,
      height: beamHeight * beamProgress,
      child: Opacity(
        opacity: (1.0 - beamProgress).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                beamColor.withValues(alpha: 0.8),
                beamColor.withValues(alpha: 0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
