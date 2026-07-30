import 'package:flutter/material.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/map/models/projection.dart';
import 'package:grimoji/features/map/models/level_node.dart' as type;
import 'package:grimoji/features/map/utils/world_physics.dart';
import 'package:grimoji/features/map/widgets/level_nodes/node/index.dart';
import 'package:provider/provider.dart';


class LevelNodes extends StatelessWidget {
  final double roadCenter;
  final double cameraZ;
  final double screenWidth;
  final double screenHeight;
  final List<type.LevelNode> nodes;

  const LevelNodes({
    super.key,
    required this.roadCenter,
    required this.cameraZ,
    required this.screenWidth,
    required this.screenHeight,
    required this.nodes,
  });

  static const double _nodeSquashY = 0.55;

  @override
  Widget build(BuildContext context) {
    final levelData = context.watch<LevelDataController>();
    if (!levelData.isInitialized) {
      return const SizedBox();
    }

    final List<Widget> visibleNodes = [];
    final List<MapEntry<type.LevelNode, Projection>> projectedNodes = [];

    for (final node in nodes) {
      final Projection proj = WorldPhysics.project(
        worldX: roadCenter,
        worldZ: node.worldZ,
        cameraZ: cameraZ,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      );

      if (proj.isVisible) {
        projectedNodes.add(MapEntry(node, proj));
      }
    }

    projectedNodes.sort((a, b) {
      return b.value.depth.compareTo(a.value.depth);
    });

    for (final data in projectedNodes) {
      final type.LevelNode node = data.key;
      final Projection proj = data.value;
      final GameLevel level = gameLevels[node.levelNumber - 1];

      final bool isUnlocked =
          node.levelNumber == 1 ||
          levelData.isLevelCompleted(node.levelNumber - 1);

      const double baseSize = 100.0;

      visibleNodes.add(
        Positioned(
          left: proj.x - (baseSize / 2),
          top: proj.y - (baseSize / 2),
          child: Opacity(
            opacity: proj.opacity,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(
                proj.scale,
                proj.scale * _nodeSquashY,
                1.0,
              ),
              child: LevelNode(
                level: level,
                stars: levelData.getStars(node.levelNumber),
                crimsonStars: levelData.getCrimsonStars(node.levelNumber),
                cacheSize: baseSize,
                isUnlocked: isUnlocked,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(children: [...visibleNodes]);
  }
}
