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

    final p = beam.progress;
    final exactBeamHeight = beam.targetY - beam.ufoY - 25;

    return Positioned(
      left: beam.targetX - (tileWidth * 0.005),
      top: beam.ufoY + (tileHeight * 0.67),
      width: tileWidth * 0.5,
      height: exactBeamHeight,
      child: Align(
        alignment: Alignment.topCenter,
        child: FractionallySizedBox(
          heightFactor: p < 0.5 ? (p * 2) : 1.0,
          child: Opacity(
            opacity: p < 0.5 ? 1.0 : (1.0 - ((p - 0.5) * 2)).clamp(0.0, 1.0),
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
        ),
      ),
    );
  }
}
