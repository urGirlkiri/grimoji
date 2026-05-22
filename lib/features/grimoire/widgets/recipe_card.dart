import 'package:flutter/material.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/widgets/emoji_widget.dart';
import 'package:provider/provider.dart';

class RecipeCard extends StatelessWidget {
  final bool isUnlocked;
  final Recipe recipe;
  
  const RecipeCard({super.key, required this.isUnlocked, required this.recipe});

  void _dialog(BuildContext context, Palette palette) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          child: Stack(
            children: [
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: palette.midnight,
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
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 128,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 2),
                            EmojiWidget.lottie(path: recipe.ingredient.lottie, size: 128),
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
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset('assets/icons/app/close.png'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.read<Palette>();
    final size = MediaQuery.sizeOf(context);

    return GestureDetector(
      onTap: () {
        if (isUnlocked) _dialog(context, palette);
      },
      child: Container(
        decoration: BoxDecoration(
          color: palette.midnight,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Image.asset(
                'assets/images/grimoire/card-frame.png',
                fit: BoxFit.fill,
              ),
            ),
            Center(
              child: isUnlocked
                  ? EmojiWidget.svg(
                      path: recipe.yields.svg,
                      size: size.width > 900 ? 80 : 48,
                    )
                  : Image.asset('assets/images/grimoire/queston_mark.png'),
            ),
          ],
        ),
      ),
    );
  }
}