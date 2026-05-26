import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:provider/provider.dart';

class LevelHintScreen extends StatefulWidget {
  final int level;
  const LevelHintScreen({super.key, required this.level});

  @override
  State<LevelHintScreen> createState() => _LevelHintScreenState();
}

class _LevelHintScreenState extends State<LevelHintScreen> {
  bool _showTutorial = false;
  Recipe? _tutorialRecipe;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLevelStatusAndRoute();
    });
  }

  Future<void> _checkLevelStatusAndRoute() async {
    final controller = context.read<LevelDataController>();
    final currentLevel = gameLevels[widget.level - 1];

    _tutorialRecipe = RecipeBook.allRecipes.cast<Recipe?>().firstWhere(
      (r) => r!.yields == currentLevel.targetEmoji,
      orElse: () => null,
    );

    final stars = controller.getStars(widget.level);

    if (stars == 0 && _tutorialRecipe != null) {
      setState(() {
        _showTutorial = true;
      });
    }

    final delay = _showTutorial ? 2500 : 1500;

    await Future.delayed(Duration(milliseconds: delay));
    if (!mounted) return;

    context.replaceNamed(
      Routes.levelPlay,
      pathParameters: {'level': widget.level.toString()},
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.voidBlack,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/emo_2.png', fit: BoxFit.cover),
          ),
          Center(
            child: _showTutorial
                ? _buildRecipeTutorial(palette)
                : _buildStandardLoading(palette),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeTutorial(Palette palette) {
    final recipe = _tutorialRecipe!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4),
          child: Text(
            "Match ${recipe.requiredAmount} to craft",
            textAlign: TextAlign.center,
            style: GoogleFonts.eagleLake(
              color: palette.moonlight,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
            ),
          ),
        ),
        const SizedBox(height: 100),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.rotate(
                angle: -15 * (math.pi / 180),
                child: Column(
                  children: List.generate(
                    recipe.requiredAmount,
                    (index) => Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: palette.twilight.withValues(alpha: .8),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: palette.magicCyan.withValues(alpha: .5),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: palette.magicCyan.withValues(
                                    alpha: .2,
                                  ),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: EmojiWidget.svg(
                              path: recipe.ingredient.svg,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.double_arrow_rounded,
                color: palette.magicCyan,
                size: 32,
              ),
              const SizedBox(width: 16),
              EmojiWidget.lottie(
                path: recipe.yields.lottie,
                useDropShadow: true,
                size: 80,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildStandardLoading(Palette palette) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        EmojiWidget.lottie(
          path: Emojis.package.lottie,
          useDropShadow: false,
          size: 120,
        ),
        const SizedBox(height: 20),
        Text(
          "Gathering ingredients...",
          style: GoogleFonts.caudex(color: palette.mist, fontSize: 24),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
