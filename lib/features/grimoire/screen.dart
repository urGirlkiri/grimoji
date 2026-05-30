import 'package:flutter/material.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/grimoire/widgets/recipe_card.dart';
import 'package:grimoji/utils/context_data.dart';

class GrimoireScreen extends StatelessWidget {
  final List<Recipe> recipes = RecipeBook.allRecipes;
  const GrimoireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final profile = context.watchProfile;

    if (!profile.isLoaded) {
      return Scaffold(
        backgroundColor: palette.midnight,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final screenWidth = context.screenWidth;

    final String? targetAutoOpenId = profile.unreadRecipeCount > 0
        ? profile.unreadRecipeIds.first
        : null;

    return Scaffold(
      backgroundColor: palette.midnight,
      body: GridView.builder(
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
          return RecipeCard(
            isUnlocked: profile.isRecipeUnlocked(recipe.id),
            isUnread: profile.isRecipeUnread(recipe.id),
            autoOpen: recipe.id == targetAutoOpenId,
            recipe: recipe,
          );
        },
      ),
    );
  }
}
