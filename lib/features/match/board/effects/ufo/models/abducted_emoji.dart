import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/constants.dart';

class AbductedEmoji {
  final GameEmoji emoji;
  final double startX;
  final double startY;
  final double startTime;

  double _progress = 0.0;
  bool _isComplete = false;

  AbductedEmoji({
    required this.emoji,
    required this.startX,
    required this.startY,
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
