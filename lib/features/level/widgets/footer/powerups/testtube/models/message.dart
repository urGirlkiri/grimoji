import 'dart:isolate';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/models/tile.dart';

class AnalysisMessage {
  final List<List<Tile>> grid;
  final TileCoordinate target;
  final SendPort sendPort;

  AnalysisMessage({
    required this.grid,
    required this.target,
    required this.sendPort,
  });
}
