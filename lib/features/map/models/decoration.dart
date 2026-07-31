import 'package:grimoji/config/emojis/index.dart';

class Decoration {
  final double worldZ;

  final double lateralOffset;

  final GameEmoji emoji;
  final double sizeScale;

  const Decoration({
    required this.worldZ,
    required this.lateralOffset,
    required this.emoji,
    this.sizeScale = 1.0,
  });
}
