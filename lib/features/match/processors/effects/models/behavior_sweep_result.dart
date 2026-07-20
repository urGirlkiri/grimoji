import 'package:grimoji/features/match/processors/effects/models/line_clear_event.dart';
import 'package:grimoji/features/match/types.dart';

class BehaviorSweepResult {
  final TileSet consumedTiles;
  final TileSet clearedLines;
  final List<LineClearEvent> lineClearEvents;
  final bool hasBoardChanged;

  BehaviorSweepResult({
    required this.consumedTiles,
    required this.clearedLines,
    required this.lineClearEvents,
    required this.hasBoardChanged,
  });
}
