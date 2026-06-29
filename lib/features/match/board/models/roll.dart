import 'package:grimoji/features/match/board/models/coordinate.dart';
import 'package:uuid/uuid.dart';

class RollEffect {
  final String id;
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
    String? id,
  }) : id = id ?? const Uuid().v4();
}
