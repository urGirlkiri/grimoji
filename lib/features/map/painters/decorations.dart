import 'package:flutter/material.dart' hide Decoration;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/map/models/level_node.dart';
import 'package:grimoji/features/map/models/decoration.dart';
import 'package:grimoji/features/map/models/projection.dart';
import 'package:grimoji/features/map/utils/world_physics.dart';

class Decorations extends StatefulWidget {
  final double cameraZ;
  final List<GameLevel> gameLevels;
  final List<LevelNode> levelNodes;
  final double maxWorldZ;
  final double width;
  final double height;

  const Decorations({
    super.key,
    required this.cameraZ,
    required this.gameLevels,
    required this.levelNodes,
    required this.maxWorldZ,
    required this.width,
    required this.height,
  });

  @override
  State<Decorations> createState() => _DecorationsState();
}

class _DecorationsState extends State<Decorations> {
  final List<Decoration> _items = [];
  static const double _levelSpacing = 20.0;

  @override
  void initState() {
    super.initState();
    _generateDecor();
  }

  void _generateDecor() {
    for (int i = 0; i < widget.gameLevels.length; i++) {
      final level = widget.gameLevels[i];
      final z = widget.levelNodes[i].worldZ;

      final targetSide = i.isEven ? 1.0 : -1.0;
      _items.add(
        Decoration(
          worldZ: z,
          lateralOffset: targetSide * 220.0,
          emoji: level.targetEmoji,
          sizeScale: 1.1,
        ),
      );

      final available = level.availableEmojis;
      for (int j = 0; j < available.length; j++) {
        final side = ((i + j) % 2 == 0) ? 1.0 : -1.0;
        final lateral = 140.0 + (j % 4) * 50.0;
        final stagger = (j - (available.length - 1) / 2.0) * 8.0;
        _items.add(
          Decoration(
            worldZ: (z + stagger).clamp(0.0, widget.maxWorldZ),
            lateralOffset: side * lateral,
            emoji: available[j],
            sizeScale: 0.85 + (j % 4) * 0.06,
          ),
        );
      }
    }

    final usedEmojis = <GameEmoji>{
      for (final level in widget.gameLevels) ...{
        level.targetEmoji,
        ...level.availableEmojis,
      },
    };
    final leftover = Emojis.all.where((e) => !usedEmojis.contains(e)).toList();
    if (leftover.isNotEmpty && widget.levelNodes.isNotEmpty) {
      final startZ = widget.levelNodes.last.worldZ + _levelSpacing;
      final endZ = widget.maxWorldZ;
      int i = 0;
      for (double z = startZ; z <= endZ; z += 25.0) {
        final side = i.isEven ? 1.0 : -1.0;
        final lateral = 180.0 + ((i % 3) * 50.0);
        _items.add(
          Decoration(
            worldZ: z,
            lateralOffset: side * lateral,
            emoji: leftover[i % leftover.length],
            sizeScale: 0.9 + (i % 3) * 0.05,
          ),
        );
        i++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final projected = <MapEntry<Decoration, Projection>>[];

    for (final item in _items) {
      const double pathCenterX = 3;
      final double worldX = pathCenterX + item.lateralOffset;

      final proj = WorldPhysics.project(
        worldX: worldX,
        worldZ: item.worldZ,
        cameraZ: widget.cameraZ,
        screenWidth: widget.width,
        screenHeight: widget.height,
      );

      if (proj.isVisible) {
        projected.add(MapEntry(item, proj));
      }
    }

    projected.sort((a, b) => b.value.depth.compareTo(a.value.depth));

    return Stack(
      children: [
        for (final entry in projected)
          Builder(
            builder: (context) {
              final item = entry.key;
              final proj = entry.value;
              final double scale = proj.scale * item.sizeScale;
              final double size = 28.0 * scale;
              final double left = proj.x - size / 2;
              final double top = proj.y - size / 2;

              return Positioned(
                left: left,
                top: top,
                child: Opacity(
                  opacity: proj.opacity,
                  child: SvgPicture.asset(
                    item.emoji.svg,
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
