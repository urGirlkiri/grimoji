import 'package:flutter/material.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/map/models/level_node.dart';
import 'package:logging/logging.dart';

class MapState extends ChangeNotifier {
  static const double _firstLvZ = 10;
  static const double _levelSpacing = 20;

  late final double _maxWorldZ;

  final List<LevelNode> _lvNodes = [];
  final LevelDataController _lvData;
  final Logger _logger = Logger('MapState');

  double _cameraZ = 0.0;
  bool? isBelowLevel;

  MapState({required LevelDataController lvData}) : _lvData = lvData {
    _genLevelNodes();
  }

  double get cameraZ => _cameraZ;
  double get maxWorldZ => _maxWorldZ;

  List<LevelNode> get lvNodes => _lvNodes;

  void handlePanUpdate(DragUpdateDetails details) {
    _cameraZ -= details.delta.dy * 2.2;
    _cameraZ = _cameraZ.clamp(0.0, _maxWorldZ);
    checkLvOutOfView();
    notifyListeners();
  }

  void checkLvOutOfView() {
    final lv = _lvFromNumber(_lvData.currentLevel());
    isBelowLevel = null;

    if (cameraZ > (lv.worldZ - _firstLvZ)) {
      isBelowLevel = true;
    }

    if (lv.levelNumber != 1) {
      if (cameraZ < (lv.worldZ - (_levelSpacing + _firstLvZ))) {
        isBelowLevel = false;
      }
    }
    _logger.info("First Level Z: $_firstLvZ");
    _logger.info("Current Level: ${lv.levelNumber}");
    _logger.info("Camera Z: $cameraZ");
    _logger.info("Current Level Z: ${lv.worldZ - _firstLvZ}");
    _logger.info("Is Below Level $isBelowLevel");
  }

  void goToCurrentLv() {
    _logger.info("Naving to Current");
    final lv = _lvFromNumber(_lvData.currentLevel());
    _logger.info("Current Level: ${lv.levelNumber}");
    _logger.info("Init Camera Z: $cameraZ");
    _cameraZ = lv.levelNumber == 1 ? 0 : lv.worldZ - _firstLvZ;
    _logger.info("Final Camera Z: $cameraZ");
    checkLvOutOfView();
    notifyListeners();
  }

  LevelNode _lvFromNumber(int num) {
    final lv = _lvNodes.firstWhere((lv) => lv.levelNumber == num);
    return lv;
  }

  void _genLevelNodes() {
    double currentZ = 10.0;
    for (final level in gameLevels) {
      _lvNodes.add(LevelNode(levelNumber: level.number, worldZ: currentZ));
      currentZ += _levelSpacing;
    }
    _maxWorldZ = currentZ + 800.0;
  }
}
