import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/map/models/level_node.dart';
import 'package:grimoji/features/map/painters/ground.dart';
import 'package:grimoji/features/map/painters/road/index.dart';
import 'package:grimoji/features/map/painters/road/stripe.dart';
import 'package:grimoji/features/map/widgets/level_nodes/index.dart';
import 'package:grimoji/features/map/widgets/sky.dart';

class LevelsMapScreen extends StatefulWidget {
  const LevelsMapScreen({super.key});

  @override
  State<LevelsMapScreen> createState() => _LevelsMapScreenState();
}

class _LevelsMapScreenState extends State<LevelsMapScreen> {
  static const double _levelSpacing = 20.0;
  static const double _roadCenter = 2;

  double _cameraZ = 0.0;
  late final double _maxWorldZ;

  final List<LevelNode> _lvNodes = [];

  @override
  void initState() {
    super.initState();
    _genLevelNodes();
  }

  void _genLevelNodes() {
    double currentZ = 10.0;
    for (final level in gameLevels) {
      _lvNodes.add(LevelNode(levelNumber: level.number, worldZ: currentZ));
      currentZ += _levelSpacing;
    }
    _maxWorldZ = currentZ + 800.0;
  }


  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _cameraZ -= details.delta.dy * 2.2;
      _cameraZ = _cameraZ.clamp(0.0, _maxWorldZ);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;

          return GestureDetector(
            onVerticalDragUpdate: _handlePanUpdate,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: mapSkyColor,
              child: Stack(
                children: [
                  const Sky(),
                  CustomPaint(
                    size: Size(screenWidth, screenHeight),
                    painter: GroundPainter(),
                  ),
                  CustomPaint(
                    size: Size(screenWidth, screenHeight),
                    painter: RoadPainter(
                      cameraZ: _cameraZ,
                      center: _roadCenter,
                      maxZ: _maxWorldZ,
                    ),
                  ),
                  CustomPaint(
                    size: Size(screenWidth, screenHeight),
                    painter: RoadStripePainter(
                      cameraZ: _cameraZ,
                      center: _roadCenter,
                      maxZ: _maxWorldZ,
                    ),
                  ),
                  LevelNodes(
                    roadCenter: _roadCenter,
                    cameraZ: _cameraZ,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    nodes: _lvNodes,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
