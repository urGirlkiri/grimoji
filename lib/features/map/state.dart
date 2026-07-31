import 'package:flutter/material.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/map/models/level_node.dart';
import 'package:logging/logging.dart';

class MapState extends ChangeNotifier {
  static const double firstLvZ = 10;
  static const double levelSpacing = 20;

  late final double _maxWorldZ;

  final List<LevelNode> _lvNodes = [];
  final Logger _logger = Logger('MapState');

  double _cameraZ = 0.0;
  bool? isBelowLevel;

  MapState() {
    _genLevelNodes();
  }

  double get cameraZ => _cameraZ;
  double get maxWorldZ => _maxWorldZ;

  List<LevelNode> get lvNodes => _lvNodes;

  void handlePanUpdate(
    DragUpdateDetails details,
    int levelNumber,
  ) {
    _cameraZ -= details.delta.dy * 2.2;
    _cameraZ = _cameraZ.clamp(0.0, _maxWorldZ);
    checkLvOutOfView(levelNumber);
    notifyListeners();
  }

  void checkLvOutOfView(int levelNumber) {
    final lv = _lvNodes.firstWhere((lv) => lv.levelNumber == levelNumber);
    if (cameraZ >= lv.worldZ) {
      isBelowLevel = true;
    }

    if (cameraZ <= lv.worldZ){
      isBelowLevel = false;
    }
    _logger.info("First Level Z: $firstLvZ");
    _logger.info("Current Level: ${lv.levelNumber}");
    _logger.info("Camera Z: $cameraZ");
    _logger.info("Current Level Z: ${lv.worldZ}");
    _logger.info("Is Out of View: $isBelowLevel");
  }

  void goToCurrentLv() {

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
