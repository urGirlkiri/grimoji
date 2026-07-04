import 'package:grimoji/features/match/board/effects/manager.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';

class RollEffect extends BoardEffect {
  final int startRow;
  final int startCol;
  final bool isHorizontal;
  final bool isWrapping;
  final List<TileCoordinate> steps;

  RollEffect({
    required this.startRow,
    required this.startCol,
    required this.isHorizontal,
    required this.isWrapping,
    required this.steps,
  }) : super();
}
