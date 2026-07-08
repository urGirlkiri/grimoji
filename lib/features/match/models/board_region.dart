import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/types.dart';

class BoardRegion {
  final TileSet coordinates;

  BoardRegion(this.coordinates);

  BoardRegion.empty() : coordinates = {};

  bool contains(TileCoordinate coord) => coordinates.contains(coord);

  bool get isEmpty => coordinates.isEmpty;

  bool get isNotEmpty => coordinates.isNotEmpty;

  int get size => coordinates.length;

  Set<int> get affectedRows => coordinates.map((c) => c.row).toSet();

  Set<int> get affectedCols => coordinates.map((c) => c.col).toSet();

  BoardRegion merge(BoardRegion other) =>
      BoardRegion({...coordinates, ...other.coordinates});

  BoardRegion difference(BoardRegion other) =>
      BoardRegion(coordinates.difference(other.coordinates));

  @override
  String toString() =>
      'BoardRegion(size: $size, rows: $affectedRows, cols: $affectedCols)';
}
