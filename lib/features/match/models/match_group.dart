import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/models/board_region.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/types.dart';

class MatchGroup {
  final GameEmoji emoji;
  final TileSet coordinates;

  final GameEmoji? yields;
  final TileCoordinate? pivot;

  bool get isSpecial => yields != null;

  BoardRegion get region => BoardRegion(coordinates);

  MatchGroup({
    required this.emoji,
    required this.coordinates,
    this.yields,
    this.pivot,
  });
}

extension MatchGroupListExtension on Iterable<MatchGroup> {
  BoardRegion get combinedRegion =>
      BoardRegion(expand((g) => g.coordinates).toSet());

  TileSet get combinedCoordinates => expand((g) => g.coordinates).toSet();
}
