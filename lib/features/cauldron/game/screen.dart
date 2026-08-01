import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/features/cauldron/game/index.dart';
import 'package:grimoji/features/cauldron/game/widgets/bottom_powerups.dart';
import 'package:grimoji/features/cauldron/game/widgets/next_card.dart';
import 'package:grimoji/features/cauldron/game/widgets/score_card.dart';
import 'package:grimoji/features/level/hint_screen/loading.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';
import 'package:grimoji/widgets/responsive_screen.dart';

class CauldronPlayScreen extends StatefulWidget {
  const CauldronPlayScreen({super.key});

  @override
  State<CauldronPlayScreen> createState() => _CauldronPlayScreenState();
}

class _CauldronPlayScreenState extends State<CauldronPlayScreen> {
  
  late final CauldronGame _game;
  bool _isGameInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isGameInitialized) {
      _game = CauldronGame(
        colorScheme: context.theme.colorScheme,
        globalScale: context.globalScale,
        context: context,
      );
      _isGameInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/emo.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: ResponsiveScreen(
        topMessageArea: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: ShapeDecoration(
            color: palette.twilight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Row(
            children: [
              AppIcon(
                fileName: _game.paused ? 'resume' : 'pause',
                enableAnimation: false,
                onTap: () {
                  setState(() {
                    _game.paused ? _game.resumeEngine() : _game.pauseEngine();
                  });
                },
              ),
              const Spacer(),
              const ScoreCard(),
              const Spacer(),
              const NextCard(),
            ],
          ),
        ),
        squarishMainArea: Column(
          children: [
            Expanded(
              child: GameWidget(
                game: _game,
                loadingBuilder: (context) => const Center(child: Loading()),
              ),
            ),
          ],
        ),
        rectangularMenuArea: const BottomPowerups(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _game.dispose();
  }
}
