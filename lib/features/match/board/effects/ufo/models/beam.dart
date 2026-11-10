import 'package:grimoji/features/match/board/effects/ufo/models/beam_type.dart';
import 'package:grimoji/features/match/constants.dart';

class BeamAnimation {
  final double targetX;
  final double targetY;
  final double ufoY; 

  final UFOBeamType beamType;
  final double startTime;

  double _progress = 0.0;
  bool _isComplete = false;

  BeamAnimation({
    required this.targetX,
    required this.targetY,
    required this.ufoY,
    required this.beamType,
    required this.startTime,
  });

  void update(double currentTime) {
    final elapsed = currentTime - startTime;
    final beamSpan =
        ufoBeamDuration.inMilliseconds / ufoFlyDuration.inMilliseconds;
    _progress = (elapsed / beamSpan).clamp(0.0, 1.0);
    if (_progress >= 1.0) {
      _isComplete = true;
    }
  }

  double get progress => _progress;
  bool get isComplete => _isComplete;
}
