import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/recipes/models/recipe.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/level/hint_screen/match_shape.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:provider/provider.dart';

class LevelHintScreen extends StatefulWidget {
  final int level;
  final List<String> startingBoosters;

  const LevelHintScreen({
    super.key,
    required this.level,
    this.startingBoosters = const [],
  });

  @override
  State<LevelHintScreen> createState() => _LevelHintScreenState();
}

class _LevelHintScreenState extends State<LevelHintScreen> {
  Recipe? _recipe;
  bool _isTargetRecipe = false;

  @override
  void initState() {
    super.initState();
    _initializeRecipe();
    _navAfterDelay();
  }

  void _initializeRecipe() {
    final controller = context.read<LevelDataController>();
    final currentLevel = gameLevels[widget.level - 1];

    var recipe = RecipeBook.allRecipes.cast<Recipe?>().firstWhere(
      (r) => r!.yields == currentLevel.targetEmoji,
      orElse: () => null,
    );

    final stars = controller.getStars(widget.level);

    if (stars == 0 && recipe != null) {
      _isTargetRecipe = true;
    } else if (RecipeBook.specialRecipes.isNotEmpty) {
      recipe = RecipeBook
          .specialRecipes[Random().nextInt(RecipeBook.specialRecipes.length)];
      _isTargetRecipe = false;
    } else {
      recipe = RecipeBook.allRecipes.first;
      _isTargetRecipe = false;
    }

    _recipe = recipe;
  }

  Future<void> _navAfterDelay() async {
    final delay = _isTargetRecipe ? 2500 : 1500;
    await Future.delayed(Duration(milliseconds: delay));
    if (!mounted) return;

    final profile = context.readProfile;
    final boosters = widget.startingBoosters.toSet();
    if (profile.isFirstTime && profile.getPowerupCount('crystal_ball') > 0) {
      boosters.add('crystal_ball');
    }

    context.replaceNamed(
      Routes.levelPlay,
      pathParameters: {'level': widget.level.toString()},
      extra: {'startingBoosters': boosters.toList()},
    );
  }

  ShapeType _recipeShape(Recipe recipe) {
    if (recipe.yields == Emojis.ghost) return ShapeType.twoByTwo;
    if (recipe.yields == Emojis.bomb) return ShapeType.tShape;
    if (recipe.yields == Emojis.barberPole) return ShapeType.lShape;
    return ShapeType.line;
  }

  String _getHintText(ShapeType shapeType, Recipe recipe) {
    final visual = recipe.ingredient.visual;
    switch (shapeType) {
      case ShapeType.twoByTwo:
        return 'Match $visual to craft';
      case ShapeType.lShape:
        return 'Match $visual to craft';
      case ShapeType.tShape:
        return 'Match $visual to craft';
      case ShapeType.line:
        return 'Match ${recipe.requiredAmount} in a line to craft';
    }
  }

  @override
  Widget build(BuildContext context) {
    
    final scale = context.globalScale;

    final shape = _isTargetRecipe ? ShapeType.line : _recipeShape(_recipe!);

    return Scaffold(
      backgroundColor: palette.voidBlack,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/emo_2.png', fit: BoxFit.cover),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 4),
                  child: Text(
                    _getHintText(shape, _recipe!),
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.displayMedium!.copyWith(
                      color: palette.moonlight,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MatchShape(shape: shape, recipe: _recipe!),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.double_arrow_rounded,
                          color: palette.magicCyan,
                          size: 32 * scale,
                        ),
                        const SizedBox(width: 16),
                        EmojiWidget.lottie(
                          emoji: _recipe!.yields,
                          useDropShadow: true,
                          size: 80 * scale,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
