import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/audio/sounds.dart';
import 'package:grimoji/features/level/widgets/confetti.dart';
import 'package:grimoji/features/level/win_screen/flying_star.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:lottie/lottie.dart';

class WinGameScreen extends StatefulWidget {
  final int level;
  final int stars;

  const WinGameScreen({super.key, required this.level, required this.stars});

  @override
  State<WinGameScreen> createState() => _WinGameScreenState();
}

class _WinGameScreenState extends State<WinGameScreen> {
  bool _isNewUnlock = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.readAudio.playSfx(SfxType.celebration);
      context.readProfile.markGamePlayed();

      if (widget.level == 1) {
        context.readProfile.markTutorialComplete();
      }

      final level = gameLevels.firstWhere((l) => l.number == widget.level);
      final recipe = RecipeBook.allRecipes.cast<Recipe?>().firstWhere(
        (r) => r!.yields == level.targetEmoji,
        orElse: () => null,
      );

      if (recipe != null) {
        if (!context.readProfile.isRecipeUnlocked(recipe.id)) {
          _isNewUnlock = true;
          context.readProfile.unlockRecipe(recipe.id);
        }
      }
    });
  }

  void _onContinuePressed(BuildContext context) {
    final nextLevelNumber = widget.level + 1;
    final hasNextLevel = gameLevels.any((l) => l.number == nextLevelNumber);

    final level = gameLevels.firstWhere((l) => l.number == widget.level);

    context.read<LevelDataController>().triggerAutoOpenLevel(
      nextLevelNumber,
      _isNewUnlock ? level.targetEmoji : null,
    );

    if (hasNextLevel) {
      GoRouter.of(context).goNamed(Routes.map);
    } else {
      GoRouter.of(context).goNamed(Routes.map);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.twilight,
      body: SafeArea(
        child: Stack(
          children: [
            const SizedBox.expand(child: Confetti(isStopped: false)),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Text(
                          'VICTORY!!',
                          style: GoogleFonts.eagleLake(
                            color: palette.trueWhite,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: palette.midnight,
                                offset: const Offset(4, 4),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        for (int i = 0; i < widget.stars; i++)
                          FlyingStar(index: i, total: widget.stars),
                      ],
                    ),
                  ),

                  Flexible(
                    child: Lottie.asset(
                      'assets/lottie/star-witch.json',
                      fit: BoxFit.contain,
                      animate: true,
                      repeat: true,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: PillButton(
                      text: "Continue",
                      color: palette.magicCyan,
                      onTap: () => _onContinuePressed(context),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
