
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/level/controller.dart';
import 'package:grimoji/features/level/hint_screen/recipe.dart';
import 'package:grimoji/features/level/hint_screen/loading.dart';
import 'package:grimoji/utils/context_data.dart';
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
    final palette = context.palette;

    return Scaffold(
      backgroundColor: palette.voidBlack,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/emo_2.png', fit: BoxFit.cover),
          ),
          Center(
            child: _showTutorial
                ? RecipeTutorial(recipe: _tutorialRecipe!)
                : const Loading(),
          ),
        ],
      ),
    );
  }
}
