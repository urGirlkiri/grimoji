import 'dart:math';

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

    if (widget.autoOpen == true ) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _unlockedDialog();
      });
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
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

  void _lockedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LockedDialog();
      },
    );
  }

  void _handleTap() {
    if (widget.isUnlocked) {
      _unlockedDialog();
    } else {
      _shakeController.forward(from: 0.0).then((_) {
        if (mounted) _lockedDialog();
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
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..translateByDouble(_shakeAnim.value, 0.0, 0.0, 1.0),
            child: child,
          );
        },
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
                          child: _buildCardContent(
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
            child: _buildCardContent(
              showEmoji: widget.isUnlocked,
              emojiSize: emojiSize,
              showUnreadIndicator: widget.isUnread,
              crimsonColor: palette.crimson,
              midnightColor: palette.midnight,
              showUnreadShadow: true,
            ),
          ),
        ),
      ),
    );  
  }

  Widget _buildCardContent({
    required bool showEmoji,
    required double emojiSize,
    required bool showUnreadIndicator,
    required Color crimsonColor,
    required Color midnightColor,
    bool showUnreadShadow = false,
  }) {
    return Stack(
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
          child: showEmoji
              ? EmojiWidget.svg(path: widget.recipe.yields.svg, size: emojiSize)
              : Image.asset('assets/images/grimoire/queston_mark.png'),
        ),
        if (showUnreadIndicator)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: crimsonColor,
                shape: BoxShape.circle,
                border: Border.all(color: midnightColor, width: 2),
                boxShadow: showUnreadShadow
                    ? [
                        BoxShadow(
                          color: crimsonColor.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
      ],
    );
  }

}

