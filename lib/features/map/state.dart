import 'package:flutter/material.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/map/models/level_node.dart';

class MapState extends ChangeNotifier {
  double _cameraZ = 0.0;
  late final double levelSpacing;
  late final double _maxWorldZ;

  final List<LevelNode> _lvNodes = [];

  MapState({required this.levelSpacing,}) {
    _genLevelNodes();
  }

  double get cameraZ => _cameraZ;
  double get maxWorldZ => _maxWorldZ;
  bool? get isBelowLevel => null;

  List<LevelNode> get lvNodes => _lvNodes;

  void handlePanUpdate(DragUpdateDetails details) {
    _cameraZ -= details.delta.dy * 2.2;
    _cameraZ = _cameraZ.clamp(0.0, _maxWorldZ);
    notifyListeners();
  }

  void _genLevelNodes() {
    double currentZ = 10.0;
    for (final level in gameLevels) {
      _lvNodes.add(LevelNode(levelNumber: level.number, worldZ: currentZ));
      currentZ += levelSpacing;
    }
    _maxWorldZ = currentZ + 800.0;
  }
}
