import 'package:flutter/material.dart';
import 'package:grimoji/features/alchemy/recipes/chapter2.dart';
import 'package:grimoji/features/grimoire/widgets/recipe_card.dart';
import 'package:provider/provider.dart';
import 'package:grimoji/config/palette.dart';

class GrimoireScreen extends StatelessWidget {
  const GrimoireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.read<Palette>();


    return Scaffold(
      backgroundColor: palette.voidBlack,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: GridView.builder(
          itemCount: 24,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {

            return RecipeCard(
              isUnlocked: true, 
              recipe: chapter2Recipes[0],
              );
          },
        ),
      ),
    );
  }
}
