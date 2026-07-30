// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/config/global_keys.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/level/widgets/dialogs/cauldron_dialog.dart';
import 'package:grimoji/features/level/widgets/dialogs/start_dialog/index.dart';
import 'package:grimoji/features/map/models/_level_node.dart';
import 'package:grimoji/features/map/widgets/engine.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/utils/math.dart';
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
  static const double _perspectiveDepth = 0.003;
  static const double _mapTiltAngle = -51.0;

  final Logger _logger = Logger('LevelsMapScreen');

  List<LevelNde> _nodes = [];
  bool _isLoadingMap = true;
  bool _pendingAutoOpen = false;
  LevelDataController? _levelData;

  double _cameraZ = 0.0;
  final double _maxCameraZ = 800.0;

  @override
  void initState() {
    super.initState();
    context.readAudio.playMenuMusic();
    _loadMapData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<LevelDataController>();
    _logger.info('Seq init');
    if (_levelData != controller) {
      _levelData?.removeListener(_checkAutoOpen);
      _levelData = controller;
      _levelData!.addListener(_checkAutoOpen);
      if (_levelData!.autoOpenLvl != null && !_pendingAutoOpen) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _checkAutoOpen();
        });
      }
    }
  }

  @override
  void dispose() {
    _levelData?.removeListener(_checkAutoOpen);
    super.dispose();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _cameraZ -= details.delta.dy * 1.5;

      _cameraZ = _cameraZ.clamp(0.0, _maxCameraZ);
    });
  }

  void _checkAutoOpen() {
    _logger.info("Checking auto open : ${_levelData?.autoOpenLvl}");
    final levelData = _levelData;
    _logger.info("Is mounted: $mounted");

    if (levelData == null || !mounted) return;
    if (levelData.autoOpenLvl != null && !_pendingAutoOpen) {
      _logger.info("Handling seq auto open");
      _handleAutoOpenSequence(levelData);
    }
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
    final unlockedRecipeId = levelData.unlockedRecipeId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LevelDataController>().clearAutoOpenLevel();

      void showLevelDialog() {
        _pendingAutoOpen = false;
        if (levelNum > 0 && levelNum <= gameLevels.length) {
          _autoShowLevelDialog(gameLevels[levelNum - 1]);
        }
      }

      if (unlockedEmoji != null) {
        final startX = context.screenWidth / 2;
        final startY = context.screenHeight / 2;

        final overlayState = Overlay.of(context, rootOverlay: true);
        context.readAudio.playSfx(SfxType.recipeUnlock);

        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          RecipeFlightAnimator.launch(
            overlay: overlayState,
            startOffset: Offset(startX, startY),
            targetKey: AppKeys.grimoireNavKey,
            unlockedEmoji: unlockedEmoji,
            onComplete: () {
              if (mounted) {
                context.readAudio.playSfx(SfxType.recipeCollection);
                if (unlockedRecipeId != null) {
                  context.readProfile.completeRecipeCollection(
                    unlockedRecipeId,
                  );
                }
              }
              Future.delayed(const Duration(milliseconds: 200), () {
                showLevelDialog();
              });
            },
          );
        });
      } else {
        showLevelDialog();
      }
    });
  }

  ({Map<int, int> stars, Map<int, int> crimson, Set<int> unlocked}) _lvProgress(
    LevelDataController levelData,
  ) {
    final Map<int, int> stars = {};
    final Map<int, int> crimson = {};
    final Set<int> unlocked = {};

    for (final node in _nodes) {
      stars[node.level] = levelData.getStars(node.level);
      crimson[node.level] = levelData.getCrimsonStars(node.level);

      if (levelData.isLevelCompleted(node.level) ||
          node.level == 1 ||
          levelData.isLevelCompleted(node.level - 1)) {
        unlocked.add(node.level);
      }
    }
    return (stars: stars, crimson: crimson, unlocked: unlocked);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingMap) {
      return const Scaffold(
        backgroundColor: Color(0xFF48484f),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    context.select<LevelDataController, int>((c) => c.mapVersion);
    final bool isInitialized = context.select<LevelDataController, bool>(
      (c) => c.isInitialized,
    );

    if (!isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF48484f),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final levelProgress = _lvProgress(context.read<LevelDataController>());

    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double mapWidth = constraints.maxWidth;
          final Matrix4 perspectiveMatrix = Matrix4.identity()
            ..setEntry(3, 2, _perspectiveDepth)
            ..rotateX(degToRad(_mapTiltAngle));
          final double mapHeight = mapWidth * (mapImgHeight / mapImgWidth);

          return GestureDetector(
            onVerticalDragUpdate: _handlePanUpdate,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Transform(
                    transform: perspectiveMatrix,
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Transform.translate(
                          offset: Offset(0, _cameraZ),
                          child: SizedBox(
                            width: mapWidth,
                            height: mapHeight,
                            child: Image.asset(
                              'assets/images/map/map_visual.png',
                              fit: BoxFit.fill,
                              filterQuality: FilterQuality.low,
                            ),
                          ),
                        ),
                      ],
                    ),
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
