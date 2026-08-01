import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/features/alchemy/recipes/models/recipe.dart';
import 'package:grimoji/features/audio/sounds/sfx.dart';
import 'package:grimoji/features/grimoire/widgets/dialogs/locked.dart';
import 'package:grimoji/features/grimoire/widgets/dialogs/recipe.dart';
import 'package:grimoji/features/grimoire/layout.dart';
import 'package:grimoji/features/grimoire/widgets/recipe_card/card_face.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';
import 'package:provider/provider.dart';

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
        context.readAudio.playSfx(Sfx.recipeRead);
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
        barrierColor: palette.midnight.withValues(alpha: 0.7),
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
      context.readAudio.playSfx(Sfx.recipeLocked);
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
    
    final layoutConfig = context.read<Layout>();

    Widget card = Hero(
      tag: 'card-${widget.recipe.id}',
      flightShuttleBuilder:
          (
            flightContext,
            animation,
            flightDirection,
            fromHeroContext,
            toHeroContext,
          ) {
            final cContext = flightDirection == HeroFlightDirection.push
                ? fromHeroContext
                : toHeroContext;
            final layout = cContext.read<Layout>();

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
                return Provider.value(
                  value: layout,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(spinAnim.value),
                    child: Container(
                      decoration: BoxDecoration(
                        color: palette.midnight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FadeTransition(
                        opacity: fadeOutAnim,
                        child: CardFace(
                          recipe: widget.recipe,
                          showEmoji: true,
                          showUnreadIndicator: widget.isUnread,
                          crimsonColor: palette.crimson,
                          midnightColor: palette.midnight,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
      child: Provider.value(
        value: layoutConfig,
        child: Container(
          decoration: BoxDecoration(
            color: palette.midnight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: CardFace(
            recipe: widget.recipe,
            showEmoji: widget.isUnlocked,
            showUnreadIndicator: widget.isUnread,
            crimsonColor: palette.crimson,
            midnightColor: palette.midnight,
            showUnreadShadow: true,
          ),
        ),
      ),
    );

    if (_isShaking) {
      card = card.animate().shake(hz: 5, rotation: 0.08, duration: 400.ms);
    }

    return RepaintBoundary(
      child: GestureDetector(onTap: _handleTap, child: card),
    );
  }
}
