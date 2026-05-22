import 'package:flutter/material.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/grimoire/widgets/recipe_card.dart';
import 'package:provider/provider.dart';
import 'package:grimoji/config/palette.dart';

class GrimoireScreen extends StatelessWidget {
  final List<Recipe> recipes = RecipeBook.allRecipes;
  const GrimoireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.read<Palette>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: palette.voidBlack,
      appBar: AppBar(
        title: Center(child: Text('Collect All The Recipes', style: theme.textTheme.titleMedium ,)),
      ),
      body: GridView.builder(
        itemCount: 24,
        padding: const EdgeInsets.only(right: 16.0, left: 8.0, bottom: 24.0, top: 12.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return RecipeCard(
            isUnlocked: true, 
            recipe: recipe,
            );
        },
      ),
    );
  }
}
