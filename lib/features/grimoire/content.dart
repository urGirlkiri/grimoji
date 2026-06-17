import 'package:flutter/material.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/grimoire/layout.dart';
import 'package:grimoji/features/grimoire/widgets/recipe_card/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class ScreenContent extends StatelessWidget {
  final Set<String> unlockedRecipes;
  final Set<String> unreadRecipes;
  final String? targetAutoOpenId;

  const ScreenContent({
    super.key,
    required this.unlockedRecipes,
    required this.unreadRecipes,
    this.targetAutoOpenId,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final screenWidth = context.screenWidth;
    final recipes = RecipeBook.allRecipes;

    final double emojiSize = screenWidth > 900 ? 80.0 : 48.0;
    final layoutConfig = Layout(
      emojiSize: emojiSize,
      cacheSize: emojiSize * dpr,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: Image.asset(
                'assets/images/emo_2.png',
                fit: BoxFit.cover,
                cacheWidth: (size.width * dpr).round(),
                cacheHeight: (size.height * dpr).round(),
                filterQuality: FilterQuality.high,
                gaplessPlayback: true,
              ),
            ),
          ),
          Provider.value(
            value: layoutConfig,
            child: GridView.builder(
              itemCount: recipes.length,
              padding: EdgeInsets.only(
                right: screenWidth > 900 ? 16.0 : 8.0,
                left: 8.0,
                bottom: 24.0,
                top: 12.0,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final bool isUnlocked = unlockedRecipes.contains(recipe.id);
                final bool isUnread = unreadRecipes.contains(recipe.id);
                final bool autoOpen = recipe.id == targetAutoOpenId;

                return RecipeCard(
                  isUnlocked: isUnlocked,
                  isUnread: isUnread,
                  autoOpen: autoOpen,
                  recipe: recipe,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}