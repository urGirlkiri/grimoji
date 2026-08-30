import 'package:grimoji/features/match/board/effect/models/board_effect.dart';
import 'package:grimoji/features/match/models/coordinate.dart';

class BloodDropEffect extends BoardEffect {
  final TileCoordinate coord;

  BloodDropEffect({required this.coord}) : super();
}
