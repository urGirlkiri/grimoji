import 'package:flutter/material.dart' hide Decoration;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/map/models/decoration.dart';
import 'package:grimoji/features/map/models/level_node.dart';
import 'package:grimoji/features/map/models/projection.dart';
import 'package:grimoji/features/map/physics.dart';
import 'package:grimoji/features/map/state.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class Decorations extends StatefulWidget {
  final double width;
  final double height;

  const Decorations({super.key, required this.width, required this.height});

  @override
  State<Decorations> createState() => _DecorationsState();
}

class _DecorationsState extends State<Decorations> {
  static const double _levelSpacing = 20.0;
  static const double _targetSpacing = 110.0;
  static const double _availableSpacing = 140.0;
  static const double _leftOverSpacing = 180.0;

  double _scale = 1;
  
  late final List<Decoration> _items;
  late final double _maxWorldZ;
  late final List<LevelNode> _levelNodes;

  @override
  void initState() {
    super.initState();
    final mapState = context.read<MapState>();

    _maxWorldZ = mapState.maxWorldZ;
    _levelNodes = mapState.lvNodes;
    _items = [];
    _generateDecor();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scale = context.globalScale;
  }

  void _generateDecor() {
    final scale = _scale;
    for (int i = 0; i < gameLevels.length; i++) {
      final level = gameLevels[i];
      final z = _levelNodes[i].worldZ;

      final targetSide = i.isEven ? 1.0 : -1.0;
      _items.add(
        Decoration(
          worldZ: z,
          lateralOffset: targetSide * _targetSpacing * scale,
          emoji: level.targetEmoji,
          sizeScale: 1.1,
        ),
      );

      final available = level.availableEmojis;
      for (int j = 0; j < available.length; j++) {
        final side = ((i + j) % 2 == 0) ? 1.0 : -1.0;
        final lateral = (_availableSpacing * scale) + (j % 4) * 50.0;
        final stagger = (j - (available.length - 1) / 2.0) * 8.0;
        _items.add(
          Decoration(
            worldZ: (z + stagger).clamp(0.0, _maxWorldZ),
            lateralOffset: side * lateral,
            emoji: available[j],
            sizeScale: 0.85 + (j % 4) * 0.06,
          ),
        );
      }
    }

    final usedEmojis = <GameEmoji>{
      for (final level in gameLevels) ...{
        level.targetEmoji,
        ...level.availableEmojis,
      },
    };
    final leftover = Emojis.all.where((e) => !usedEmojis.contains(e)).toList();
    if (leftover.isNotEmpty && _levelNodes.isNotEmpty) {
      final startZ = _levelNodes.last.worldZ + _levelSpacing;
      final endZ = _maxWorldZ;
      int i = 0;
      for (double z = startZ; z <= endZ; z += 25.0) {
        final side = i.isEven ? 1.0 : -1.0;
        final lateral = _leftOverSpacing + ((i % 3) * 50.0);
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
    final cameraZ = context.watch<MapState>().cameraZ;
    final projected = <MapEntry<Decoration, Projection>>[];

    for (final item in _items) {
      final double worldX = 3 + item.lateralOffset;

      final proj = WorldPhysics.project(
        worldX: worldX * _scale,
        worldZ: item.worldZ * _scale,
        cameraZ: cameraZ,
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
              final double size = 28.0 * scale * _scale;
              final double left = proj.x - size / 2 * _scale;
              final double top = proj.y - size / 2 + 20;

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
