import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/grimoire/widgets/dialogs/locked.dart';
import 'package:grimoji/features/grimoire/widgets/dialogs/recipe.dart';
import 'package:grimoji/features/grimoire/widgets/recipe_card/card_face.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';

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

class _RecipeCardState extends State<RecipeCard> {
  bool _isShaking = false;

  @override
  void initState() {
    super.initState();

    if (widget.autoOpen == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _unlockedDialog();
      });
    }
  }

  void _unlockedDialog() {
    if (widget.isUnread) {
      context.readProfile.markRecipeAsRead(widget.recipe.id);
    }

    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: context.palette.midnight.withValues(alpha: 0.7),
        transitionDuration: const Duration(milliseconds: 1000),
        reverseTransitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: RecipeDialog(recipe: widget.recipe),
          );
        },
      ),
    );
  }


  void _handleTap() {
    if (widget.isUnlocked) {
      _unlockedDialog();
    } else {
      setState(() {
        _isShaking = true;
      });

      Future.delayed(400.ms, () {
        if (mounted) {
          setState(() {
            _isShaking = false;
          });
          showAnimatedDialog(context, const LockedDialog());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final screenWidth = context.screenWidth;
    final emojiSize = screenWidth > 900 ? 80.0 : 48.0;

    return GestureDetector(
      onTap: _handleTap,
      child: Hero(
        tag: 'card-${widget.recipe.id}',
        flightShuttleBuilder:
            (
              flightContext,
              animation,
              flightDirection,
              fromHeroContext,
              toHeroContext,
            ) {
              final spinAnim = Tween<double>(begin: 0, end: 4 * pi).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              );

              final fadeOutAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
                ),
              );

              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(spinAnim.value),
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.palette.midnight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FadeTransition(
                        opacity: fadeOutAnim,
                        child: CardFace(
                          recipe: widget.recipe,
                          showEmoji: true,
                          emojiSize: emojiSize,
                          showUnreadIndicator: widget.isUnread,
                          crimsonColor: palette.crimson,
                          midnightColor: palette.midnight,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
        child: Container(
          decoration: BoxDecoration(
            color: palette.midnight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: CardFace(
            recipe: widget.recipe,
            showEmoji: widget.isUnlocked,
            emojiSize: emojiSize,
            showUnreadIndicator: widget.isUnread,
            crimsonColor: palette.crimson,
            midnightColor: palette.midnight,
            showUnreadShadow: true,
          ),
        ),
      )
      .animate(target: _isShaking ? 1 : 0)
      .shake(
        hz: 5,
        rotation: 0.08,
        duration: 400.ms,
      ),
    );  
  }

}

