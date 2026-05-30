import 'package:flutter/material.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class RecipeDialog extends StatelessWidget {
  final Recipe recipe;
  const RecipeDialog({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Stack(
        children: [
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: context.palette.midnight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          recipe.requiredAmount.toString(),
                          style: context.theme.textTheme.displayLarge?.copyWith(
                            fontSize: 128,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        EmojiWidget.lottie(
                          path: recipe.ingredient.lottie,
                          size: 128,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Image.asset(
                      'assets/images/grimoire/down-arrow.png',
                      width: 200,
                      height: 300,
                    ),
                    const SizedBox(height: 32),
                    EmojiWidget.lottie(path: recipe.yields.lottie, size: 128),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 16.0,
            right: 16.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CorkScrewCloseButton(),
            ),
          ),
        ],
      ),
    );
  }
}
