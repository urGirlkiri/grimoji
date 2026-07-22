import 'package:grimoji/features/match/board/effect/manager.dart';
import 'package:grimoji/features/match/models/coordinate.dart';

class BloodDropEffect extends BoardEffect {
  final TileCoordinate coord;

  BloodDropEffect({required this.coord}) : super();
}
