import 'package:flutter/material.dart';
import 'package:grimoji/config/global_keys.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/audio/sounds/sfx.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/level/widgets/dialogs/cauldron_dialog.dart';
import 'package:grimoji/features/level/widgets/dialogs/start_dialog/index.dart';
import 'package:grimoji/features/map/state.dart';
import 'package:grimoji/features/map/widgets/level_finder.dart';
import 'package:grimoji/features/map/widgets/map.dart';
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
  bool _pendingAutoOpen = false;
  LevelDataController? _levelData;

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
        context.readAudio.playSfx(Sfx.recipeUnlock);

        Future.delayed(const Duration(milliseconds: 600), () {
          if (!mounted) return;
          RecipeFlightAnimator.launch(
            overlay: overlayState,
            startOffset: Offset(startX, startY),
            targetKey: AppKeys.grimoireNavKey,
            unlockedEmoji: unlockedEmoji,
            onComplete: () {
              if (mounted) {
                context.readAudio.playSfx(Sfx.recipeCollection);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (context) => MapState(lvData: _levelData!),
        child: const Stack(children: [MapWidget(), LevelFinder()]),
      ),
    );
  }
}
