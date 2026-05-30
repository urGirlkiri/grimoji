import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/config/global_keys.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/level/widgets/dialogs/cauldron_dialog.dart';
import 'package:grimoji/features/level/widgets/dialogs/start_dialog.dart';
import 'package:grimoji/features/map/models/level_node.dart';
import 'package:grimoji/features/map/widgets/engine.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';
import 'package:grimoji/widgets/animations/recipe_flight.dart';
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
  bool _pendingAutoOpen = false;

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

  void _handleAutoOpenSequence(LevelDataController levelData) {
    _pendingAutoOpen = true;
    final levelNum = levelData.autoOpenLvl!;
    final unlockedEmoji = levelData.unlockedEmoji;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LevelDataController>().clearAutoOpenLevel();

      void showLevelDialog() {
        _pendingAutoOpen = false;
        if (levelNum > 0 && levelNum <= gameLevels.length) {
          _autoShowLevelDialog(gameLevels[levelNum - 1]);
        }
      }

      if (unlockedEmoji != null) {
        final screenWidth = context.screenWidth;
        final isDarkMode = context.theme.canvasColor == Colors.black;
        final startY = isDarkMode ? 200.0 : 300.0;
        final overlayState = Overlay.of(context, rootOverlay: true);

        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          RecipeFlightAnimator.launch(
            overlay: overlayState,
            startOffset: Offset(screenWidth / 2, startY),
            targetKey: AppKeys.grimoireNavKey,
            unlockedEmoji: unlockedEmoji,
            onComplete: showLevelDialog,
          );
        });
      } else {
        showLevelDialog();
      }
    });
  }

  ({Map<int, int> stars, Set<int> unlocked}) _getLevels(
    LevelDataController levelData,
  ) {
    final Map<int, int> stars = {};
    final Set<int> unlocked = {};

    for (final node in _nodes) {
      stars[node.level] = levelData.getStars(node.level);

      if (levelData.isLevelCompleted(node.level) ||
          node.level == 1 ||
          levelData.isLevelCompleted(node.level - 1)) {
        unlocked.add(node.level);
      }
    }

    return (stars: stars, unlocked: unlocked);
  }

  @override
  Widget build(BuildContext context) {
    final levelData = context.watch<LevelDataController>();

    if (levelData.autoOpenLvl != null && !_pendingAutoOpen) {
      _handleAutoOpenSequence(levelData);
    }

    if (!levelData.isInitialized || _isLoadingMap) {
      return const Scaffold(
        backgroundColor: Color(0xFF48484f),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final levels = _getLevels(levelData);

    return Scaffold(
      backgroundColor: const Color(0xFF48484f),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double mapWidth = constraints.maxWidth;

          return SingleChildScrollView(
            reverse: true,
            child: MapEngine(
              mapWidth: mapWidth,
              nodes: _nodes,
              nodeScale: mapWidth / mapImgWidth,
              unlockedLevels: levels.unlocked,
              levelStars: levels.stars,
            ),
          );
        },
      ),
    );
  }
}
