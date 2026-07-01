import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/app/lifecycle.dart' show AppLifecycleStateNotifier;
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/level/widgets/footer/skip_btn.dart';
import 'package:grimoji/features/level/widgets/overlays/level_complete.dart';
import 'package:grimoji/features/match/board/utils/metrics.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/confetti.dart';
import 'package:grimoji/features/match/board/index.dart';
import 'package:grimoji/features/level/widgets/header/index.dart';
import 'package:grimoji/features/level/widgets/footer/index.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/level/widgets/dialogs/quit_dialog.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:grimoji/widgets/responsive_screen.dart';
import 'package:provider/provider.dart';
import 'package:logging/logging.dart' hide Level;

class LevelScreen extends StatefulWidget {
  final GameLevel level;
  final List<String> startingBoosters;

  const LevelScreen({
    super.key,
    required this.level,
    this.startingBoosters = const [],
  });

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  bool _duringCelebration = false;
  bool _isQuitDialogOpen = false;
  late final LevelState _levelState;
  late final BoardMetrics _boardMetrics;

  static final _log = Logger('LevelScreen');
  static const _celebrationDuration = Duration(milliseconds: 2000);
  static const _preCelebrationDuration = Duration(milliseconds: 500);

  void _showQuitDialog() {
    if (_isQuitDialogOpen) return;

    setState(() {
      _isQuitDialogOpen = true;
    });

    showAnimatedDialog(context, QuitDialog(level: widget.level.number)).then((
      _,
    ) {
      if (mounted) {
        setState(() {
          _isQuitDialogOpen = false;
        });
      }
    });
  }

  Future<void> _playerWon(int starsEarned) async {
    if (!mounted) return;
    _log.info('Level ${widget.level.number} won with $starsEarned stars!');

    final levelDataController = context.read<LevelDataController>();

    await levelDataController.saveLevelCompletion(
      widget.level.number,
      starsEarned,
    );

    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    context.readAudio.playSfx(SfxType.congrats);

    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    GoRouter.of(context).goNamed(
      Routes.levelWon,
      extra: {'level': widget.level.number, 'stars': starsEarned},
    );
  }

  Future<void> _playerFailed() async {
    if (!mounted) return;
    _log.info('Level ${widget.level.number} failed');

    context.readAudio.playSfx(SfxType.fail);

    if (!mounted) return;

    GoRouter.of(context).goNamed(
      Routes.levelFail,
      pathParameters: {'level': widget.level.number.toString()},
    );
  }

  void _skipFever() {
    context.readAudio.playSfx(SfxType.congrats);
    final stars = _levelState.goalManager.calculateStars();

    GoRouter.of(context).goNamed(
      Routes.levelWon,
      extra: {'level': widget.level.number, 'stars': stars},
    );
  }

  @override
  void initState() {
    super.initState();
    context.readAudio.playLevelMusic();

    _levelState = LevelState(
      onWin: _playerWon,
      onLose: _playerFailed,
      level: widget.level,
      audio: context.readAudio,
      lifecycleNotifier: context.read<AppLifecycleStateNotifier>(),
      startingBoosters: widget.startingBoosters,
    );
    _boardMetrics = BoardMetrics();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.readProfile.markGamePlayed();
      for (final boosterId in widget.startingBoosters) {
        context.readProfile.updatePowerupCount(boosterId, -1);
      }
    });
  }

  @override
  void dispose() {
    _levelState.dispose();
    _boardMetrics.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: widget.level),
        ChangeNotifierProvider.value(value: _levelState),
        ChangeNotifierProvider.value(value: _boardMetrics),
      ],
      child: Builder(
        builder: (context) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;

              if (_isQuitDialogOpen) {
                Navigator.of(context).pop();
              } else {
                _showQuitDialog();
              }
            },
            child: IgnorePointer(
              ignoring: _duringCelebration,
              child: Scaffold(
                body: Stack(
                  children: [
                    ResponsiveScreen(
                      topMessageArea: const Header(),
                      squarishMainArea: const GameBoard(),
                      rectangularMenuArea: Selector<LevelState, bool>(
                        selector: (_, state) => state.gameState.isFeverTime,
                        builder: (context, isFeverTime, child) => isFeverTime
                            ? SkipBtn(onSkip: _skipFever)
                            : const Footer(),
                      ),
                      mobileBackgroundImage: const AssetImage(
                        'assets/images/level/game.png',
                      ),
                      desktopBackgroundImage: const AssetImage(
                        'assets/images/level/large_game.png',
                      ),
                    ),
                    SizedBox.expand(
                      child: Visibility(
                        visible: _duringCelebration,
                        child: IgnorePointer(
                          child: Confetti(isStopped: !_duringCelebration),
                        ),
                      ),
                    ),

                    Selector<LevelState, Map<String, bool>>(
                      selector: (_, state) => {
                        'isGoalComplete': state.isGoalComplete,
                        'isFeverTime': state.gameState.isFeverTime,
                      },
                      builder: (context, stateMap, child) {
                        final isGoalComplete = stateMap['isGoalComplete']!;
                        final isFeverTime = stateMap['isFeverTime']!;

                        if (!isGoalComplete) return const SizedBox.shrink();

                        final controller = context.read<LevelDataController>();
                        final isFirstTime = !controller.isLevelCompleted(
                          widget.level.number,
                        );

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _levelState.startFeverSequence();
                        });

                        if (isFirstTime && !isFeverTime) {
                          return const LevelComOverlay();
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    if (kDebugMode)
                      Positioned(
                        top: 200,
                        left: 90,
                        child: PillButton(
                          text: 'FORCE FEVER',
                          color: Colors.red,
                          onTap: () => _levelState.triggerFeverForTesting(),
                          fullWidth: false,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
