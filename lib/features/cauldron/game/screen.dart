import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/cauldron/game/index.dart';
import 'package:grimoji/features/cauldron/game/widgets/bottom_powerups.dart';
import 'package:grimoji/features/cauldron/game/widgets/next_card.dart';
import 'package:grimoji/features/cauldron/game/widgets/score_card.dart';
import 'package:grimoji/features/settings/dialogs/settings.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';
import 'package:grimoji/widgets/dialogs/pause_dialog.dart';
import 'package:grimoji/widgets/dialogs/quit_dialog.dart';
import 'package:grimoji/widgets/responsive_screen.dart';
import 'package:provider/provider.dart';
import 'package:grimoji/features/cauldron/game/state.dart';
import 'package:grimoji/features/cauldron/game/dialogs/game_over.dart';

class CauldronPlayScreen extends StatefulWidget {
  const CauldronPlayScreen({super.key});

  @override
  State<CauldronPlayScreen> createState() => _CauldronPlayScreenState();
}

class _CauldronPlayScreenState extends State<CauldronPlayScreen> {
  late final CauldronGame _game;
  late final CauldronState _gameState;
  bool _isGameInitialized = false;
  bool _isPauseDialogOpen = false;
  bool _isQuitDialogOpen = false;
  bool _isGameOverDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _gameState = CauldronState();
    _gameState.addListener(_onGameStateChanged);
  }

  void _onGameStateChanged() {
    if (_gameState.isGameOver && !_isGameOverDialogOpen && mounted) {
      _showGameOverDialog();
    }
  }

  void _showGameOverDialog() {
    setState(() => _isGameOverDialogOpen = true);

    showAnimatedDialog(
      context,
      GameOverDialog(
        score: _gameState.score,
        onRetry: () {
          _game.reset();
        },
        onQuit: () {
          GoRouter.of(context).go(Routes.cauldronRoute);
        },
      ),
    ).then((_) {
      if (mounted) setState(() => _isGameOverDialogOpen = false);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isGameInitialized) {
      _game = CauldronGame(
        colorScheme: context.theme.colorScheme,
        globalScale: context.globalScale,
        context: context,
        gameState: _gameState,
      );
      _isGameInitialized = true;
    }
  }

  void _showPauseDialog() {
    if (_isPauseDialogOpen) return;
    setState(() => _isPauseDialogOpen = true);
    _game.pauseEngine();

    showAnimatedDialog(
      context,
      PauseDialog(
        onResume: () => _game.resumeEngine(),
        onQuit: () {
          GoRouter.of(context).go(Routes.cauldronRoute);
        },
        onSettings: () {
          showAnimatedDialog(context, const SettingsDialog());
        },
      ),
    ).then((_) {
      if (!mounted) return;
      if (_game.paused) _game.resumeEngine();
      setState(() => _isPauseDialogOpen = false);
    });
  }

  void _showQuitDialog() {
    if (_isQuitDialogOpen) return;
    setState(() => _isQuitDialogOpen = true);
    _game.pauseEngine();

    showAnimatedDialog(
      context,
      QuitDialog(
        onQuit: () {
          GoRouter.of(context).go(Routes.cauldronRoute);
        },
        onStay: () => _game.resumeEngine(),
      ),
    ).then((_) {
      if (!mounted) return;
      if (_game.paused) _game.resumeEngine();
      setState(() => _isQuitDialogOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _gameState,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_isQuitDialogOpen) {
            Navigator.of(context).pop();
            _game.resumeEngine();
            setState(() {});
          } else {
            _showQuitDialog();
          }
        },
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/emo.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: ResponsiveScreen(
              topMessageArea: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: ShapeDecoration(
                  color: palette.twilight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: AppIcon(
                        size: 50 * context.globalScale,
                        fileName: _game.paused ? 'resume' : 'pause',
                        enableAnimation: false,
                        onTap: () {
                          if (_game.paused) {
                            if (_isPauseDialogOpen) {
                              Navigator.of(context).pop();
                            }
                            _game.resumeEngine();
                          } else {
                            _showPauseDialog();
                          }
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 4,),
                    const Flexible(
                      flex: 2,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ScoreCard(),
                      ),
                    ),
                    const SizedBox(width: 4,),
                    const Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: NextCard(),
                      ),
                    ),
                  ],
                ),
              ),
              squarishMainArea: Column(
                children: [
                  Expanded(
                    child: GameWidget(
                      game: _game,
                      loadingBuilder: (context) => Center(
                        child: AspectRatio(
                          aspectRatio: 10.5125 / 9.573,
                          child: Image.asset(
                            'assets/images/cauldron/Cauldron.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              rectangularMenuArea: const BottomPowerups(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gameState.removeListener(_onGameStateChanged);
    _gameState.dispose();
    _game.dispose();
    super.dispose();
  }
}
