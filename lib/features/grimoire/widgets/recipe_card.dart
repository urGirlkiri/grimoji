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
      barrierColor: palette.midnight.withValues(alpha: .89),

      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            decoration: BoxDecoration(
              color: palette.midnight,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        recipe.requiredAmount.toString(),
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              fontSize: 128,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(width: 2),
                      EmojiWidget.svg(path: recipe.ingredient.svg, size: 128),
                    ],
                  ),
                  SizedBox(height: 24),
                  Image.asset(
                    'assets/images/grimoire/down-arrow.png',
                    width: 200,
                    height: 300,
                  ),
                  SizedBox(height: 24),
                  EmojiWidget.svg(path: recipe.yields.svg, size: 128),
                ],
              ),
            ),
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
        isUnlocked ? _dialog(context, palette) : null;
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
                      path: recipe.ingredient.svg,
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
