import 'package:flutter/material.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/grimoire/widgets/dialogs/locked.dart';
import 'package:grimoji/features/grimoire/widgets/dialogs/recipe.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class RecipeCard extends StatefulWidget {
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

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;

  void _handleTap() {
    if (widget.isUnlocked) {
      _recipeDialog(context);
    } else {
      _shakeController.forward(from: 0).then((_) => _lockedDialog(context));
    }
  }

  void _recipeDialog(BuildContext context) {
    if (widget.isUnread) {
      context.readProfile.markRecipeAsRead;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RecipeDialog(recipe: widget.recipe);
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
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8, end: -8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(_shakeController);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final screenWidth = context.screenWidth;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _shakeAnim,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..translateByDouble(_shakeAnim.value, 0.0, 0.0, 1.0),
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
                    child: widget.isUnlocked
                        ? EmojiWidget.svg(
                            path: widget.recipe.yields.svg,
                            size: screenWidth > 900 ? 80 : 48,
                          )
                        : Image.asset(
                            'assets/images/grimoire/queston_mark.png',
                          ),
                  ),

                  if (widget.isUnread)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: palette.crimson,
                          shape: BoxShape.circle,
                          border: Border.all(color: palette.midnight, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: palette.crimson.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
