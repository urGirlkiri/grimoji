import 'package:grimoji/config/emojis/index.dart';

class AnalysisResult {
  final GameEmoji bestEmoji;
  final String matchType;
  final int matchSize;

  AnalysisResult({
    required this.bestEmoji,
    required this.matchType,
    required this.matchSize,
  });
}
