import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/map/models/node.dart';
import 'package:grimoji/features/map/widgets/level_node.dart';
import 'package:grimoji/features/level/widgets/dialogs/start_dialog.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class LevelsMapScreen extends StatefulWidget {
  final int? autoOpenLevel;

  const LevelsMapScreen({super.key, this.autoOpenLevel});

  @override
  State<LevelsMapScreen> createState() => _LevelsMapScreenState();
}

class _LevelsMapScreenState extends State<LevelsMapScreen> {
  List<MapNode> _nodes = [];
  bool _isLoadingMap = true;

  final Logger _logger = Logger('LevelsMapScreen');

  @override
  void initState() {
    super.initState();
    _loadMapData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.autoOpenLevel != null) {
        final levelNum = widget.autoOpenLevel!;
        final level = gameLevels[levelNum - 1];
        _autoShowLevelDialog(level);
      }
    });
  }

  Future<void> _loadMapData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/data/map.json',
      );
      final List<dynamic> data = json.decode(response) as List<dynamic>;

      if (mounted) {
        setState(() {
          _nodes = data
              .map((json) => MapNode.fromJson(json as Map<String, dynamic>))
              .toList();
          _isLoadingMap = false;
        });
      }
    } catch (e) {
      _logger.severe("Error loading map data: $e");
      if (mounted) setState(() => _isLoadingMap = false);
    }
  }

  void _autoShowLevelDialog(GameLevel level) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .7),
      builder: (BuildContext context) {
        return LevelStartDialog(level: level);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final levelData = context.watch<LevelDataController>();

    final double screenWidth = MediaQuery.sizeOf(context).width;

    if (!levelData.isInitialized || _isLoadingMap) {
      return Scaffold(
        backgroundColor: palette.voidBlack,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF48484f),
      body: SingleChildScrollView(
        reverse: true,
        child: SizedBox(
          width: screenWidth,
          child: Stack(
            children: [
              Image.asset(
                "assets/images/map/map_visual.png",
                fit: BoxFit.fitWidth,
              ),

            ..._nodes.map((node) {
              if (node.level > gameLevels.length) {
                return const SizedBox.shrink();
              }

              final int levelNum = node.level;
              final int stars = levelData.getStars(levelNum);
              final bool isUnlocked =
                  levelNum == 1 || levelData.isLevelCompleted(levelNum - 1);
              final GameLevel levelDefinition = gameLevels[levelNum - 1];

              final double alignX = (node.x * 2) - 1;
              final double alignY = (node.y * 2) - 1;

              return Positioned.fill(
                child: Align(
                  alignment: Alignment(alignX, alignY),
                  child: isUnlocked
                      ? LevelNode(level: levelDefinition, stars: stars)
                      : const SizedBox.shrink(),
                ),
              );
            }),
          ],
        ),
      ),
    ));
  }
}
