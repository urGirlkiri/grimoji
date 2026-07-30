import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/global_keys.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/level/widgets/dialogs/cauldron_dialog.dart';
import 'package:grimoji/features/level/widgets/dialogs/start_dialog/index.dart';
import 'package:grimoji/features/map/models/level_node.dart';
import 'package:grimoji/features/map/painters/ground.dart';
import 'package:grimoji/features/map/painters/decorations.dart';
import 'package:grimoji/features/map/painters/road/index.dart';
import 'package:grimoji/features/map/painters/road/stripe.dart';
import 'package:grimoji/features/map/widgets/level_nodes/index.dart';
import 'package:grimoji/features/map/widgets/sky.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';
import 'package:grimoji/widgets/animations/recipe_flight.dart';
import 'package:provider/provider.dart';

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

  bool _pendingAutoOpen = false;
  LevelDataController? _levelData;

  final List<LevelNode> _lvNodes = [];

  @override
  void initState() {
    super.initState();
    _genLevelNodes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<LevelDataController>();
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

  void _genLevelNodes() {
    double currentZ = 10.0;
    for (final level in gameLevels) {
      _lvNodes.add(LevelNode(levelNumber: level.number, worldZ: currentZ));
      currentZ += _levelSpacing;
    }
    _maxWorldZ = currentZ + 800.0;
  }

  void _checkAutoOpen() {
    final levelData = _levelData;
    if (levelData == null || !mounted) return;
    if (levelData.autoOpenLvl != null && !_pendingAutoOpen) {
      _handleAutoOpenSequence(levelData);
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
                  Decorations(
                    cameraZ: _cameraZ,
                    gameLevels: gameLevels,
                    levelNodes: _lvNodes,
                    maxWorldZ: _maxWorldZ,
                    width: screenWidth,
                    height: screenHeight,
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
