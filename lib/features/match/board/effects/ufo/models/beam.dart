import 'package:grimoji/features/match/board/effects/ufo/models/beam_type.dart';

class BeamAnimation {
  final double targetX;
  final double targetY;

  final UFOBeamType beamType;
  final double startTime;
  
  double _progress = 0.0;
  bool _isComplete = false;

  BeamAnimation({
    required this.targetX,
    required this.targetY,
    required this.beamType,
    required this.startTime,
  });

  void update(double currentTime) {
    final elapsed = currentTime - startTime;
    _progress = (elapsed / 0.3).clamp(0.0, 1.0); 
    if (_progress >= 1.0) {
      _isComplete = true;
    }
  }

  double get progress => _progress;
  bool get isComplete => _isComplete;
}
