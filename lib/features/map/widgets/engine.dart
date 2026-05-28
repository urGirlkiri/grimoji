import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/map/widgets/level_node.dart';
import 'package:grimoji/features/map/widgets/temp_node.dart';

import 'package:grimoji/features/map/models/level_node.dart';

const double mapImgWidth = 755.0;
const double mapImgHeight = 1967.0;

class MapEngine extends StatelessWidget {
  final double mapWidth;
  final List<LevelNde> nodes;
  final double nodeScale;
  final void Function(LevelNde)? onDeleteNode;
  final double? hoverPercentX;
  final double? hoverPercentY;
  final Map<int, int> levelStars;
  final Set<int> unlockedLevels;
  
  final bool isPlacementMode;

  const MapEngine({
    super.key,
    required this.mapWidth,
    required this.nodes,
    required this.nodeScale,
    this.onDeleteNode,
    this.hoverPercentX,
    this.hoverPercentY,
    this.levelStars = const {},
    this.unlockedLevels = const {},
    this.isPlacementMode = false, 
  });

  @override
  Widget build(BuildContext context) {
    final double mapHeight = mapWidth * (mapImgHeight / mapImgWidth);
    
    final bool isBuilderMode = onDeleteNode != null;
    final bool isCursorMode = isBuilderMode && !isPlacementMode;

    return SizedBox(
      width: mapWidth,
      height: mapHeight,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/map/map_visual.png',
            width: mapWidth,
            height: mapHeight,
            fit: BoxFit.fill,
          ),

          ...nodes.map((node) {
            if (node.level > gameLevels.length && !isBuilderMode) return const SizedBox.shrink();

            final int levelNum = node.level;
            final int stars = levelStars[levelNum] ?? 0;
            final bool isUnlocked = unlockedLevels.contains(levelNum);
            final GameLevel levelDefinition = levelNum <= gameLevels.length 
                ? gameLevels[levelNum - 1] 
                : _previewLevel(levelNum);

            return Positioned(
              left: node.x * mapWidth,
              top: node.y * mapHeight,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Transform.scale(
                  scale: nodeScale,
                  child: isBuilderMode
                      ? TempNode(
                          isCursorMode: isCursorMode,
                          onTap: () => onDeleteNode!(node),
                          child: LevelNode(level: levelDefinition, stars: 3),
                        )
                      : (isUnlocked
                          ? LevelNode(level: levelDefinition, stars: stars)
                          : const SizedBox.shrink()),
                ),
              ),
            );
          }),

          if (isPlacementMode && hoverPercentX != null && hoverPercentY != null && isBuilderMode)
            Positioned(
              left: hoverPercentX! * mapWidth,
              top: hoverPercentY! * mapHeight,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Transform.scale(
                  scale: nodeScale,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.5,
                      child: LevelNode(
                        level: gameLevels.isNotEmpty
                            ? gameLevels[(nodes.length) % gameLevels.length]
                            : _previewLevel(nodes.length + 1),
                        stars: 0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  GameLevel _previewLevel(int number) {
    return GameLevel(
      number: number,
      timeLimit: 60,
      targetAmount: 10,
      targetEmoji: Emojis.ocean,
      goal: '',
      description: '',
      availableEmojis: [],
    );
  }
}