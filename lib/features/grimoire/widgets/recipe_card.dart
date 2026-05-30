import 'package:flutter/material.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/grimoire/widgets/dialogs/locked.dart';
import 'package:grimoji/features/grimoire/widgets/dialogs/recipe.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class RecipeCard extends StatelessWidget {
  final bool isUnlocked;
  final bool isUnread;
  final Recipe recipe;
  final bool? autoOpen;

  const RecipeCard({
    super.key,
    required this.isUnlocked,
    required this.recipe,
    required this.isUnread,
    this.autoOpen,
  });

  void _recipeDialog(BuildContext context) {
    if (isUnread) {
      context.readProfile.markRecipeAsRead;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RecipeDialog(recipe: recipe);
      },
    );
  }
  void _lockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LockedDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final screenWidth = context.screenWidth;

    return GestureDetector(
      onTap: () {
        if (isUnlocked) {
          _recipeDialog(context);
        } else {
          _lockedDialog(context);
        }
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
                      size: screenWidth > 900 ? 80 : 48,
                    )
                  : Image.asset('assets/images/grimoire/queston_mark.png'),
            ),
          ],
        ),
      ),
    );
  }
}
