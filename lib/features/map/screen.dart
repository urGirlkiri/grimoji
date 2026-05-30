import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/level/widgets/dialogs/cauldron_dialog.dart';
import 'package:grimoji/features/level/widgets/dialogs/start_dialog.dart';
import 'package:grimoji/features/map/models/level_node.dart';
import 'package:grimoji/features/map/widgets/engine.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class LevelsMapScreen extends StatefulWidget {
  const LevelsMapScreen({super.key});

  @override
  State<LevelsMapScreen> createState() => _LevelsMapScreenState();
}

class _LevelsMapScreenState extends State<LevelsMapScreen> {
  List<LevelNde> _nodes = [];
  bool _isLoadingMap = true;

  final Logger _logger = Logger('LevelsMapScreen');

  @override
  void initState() {
    super.initState();
    _loadMapData();
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
              .map((json) => LevelNde.fromJson(json as Map<String, dynamic>))
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
    final profile = context.readProfile;
    profile.checkCauldronRegen();

    if (profile.cauldrons <= 0) {
      showAnimatedDialog(context, const CauldronDialog());
    } else {
      showAnimatedDialog(context, LevelStartDialog(level: level));
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelData = context.watch<LevelDataController>();

    if (levelData.autoOpenLvl != null) {
      final levelNum = levelData.autoOpenLvl!;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<LevelDataController>().clearAutoOpenLevel();

        if (levelNum > 0 && levelNum <= gameLevels.length) {
          final level = gameLevels[levelNum - 1];
          _autoShowLevelDialog(level);
        }
      });
    }

    if (!levelData.isInitialized || _isLoadingMap) {
      return Scaffold(
        backgroundColor: const Color(0xFF48484f),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final Map<int, int> levelStars = {};

    final Set<int> unlockedLevels = {};

    for (final node in _nodes) {
      final int stars = levelData.getStars(node.level);
      levelStars[node.level] = stars;
      if (levelData.isLevelCompleted(node.level) ||
          node.level == 1 ||
          levelData.isLevelCompleted(node.level - 1)) {
        unlockedLevels.add(node.level);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF48484f),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double mapWidth = constraints.maxWidth;
          final double nodeScale = mapWidth / mapImgWidth;

          return SingleChildScrollView(
            reverse: true,
            child: MapEngine(
              mapWidth: mapWidth,
              nodes: _nodes,
              nodeScale: nodeScale,
              unlockedLevels: unlockedLevels,
              levelStars: levelStars,
            ),
          );
        },
      ),
    );
  }
}
