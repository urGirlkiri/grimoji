import 'package:flutter/material.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/grimoire/widgets/recipe_card/unread_badge.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class CardFace extends StatelessWidget {
  final Recipe recipe;
  final bool showEmoji;
  final double emojiSize;
  final bool showUnreadIndicator;
  final bool showUnreadShadow;
  final Color crimsonColor;
  final Color midnightColor;

  const CardFace({
    super.key,
    required this.recipe,
    required this.showEmoji,
    required this.emojiSize,
    required this.showUnreadIndicator,
    required this.crimsonColor,
    required this.midnightColor,
    this.showUnreadShadow = false,
  });

  @override
  Widget build(BuildContext context) {
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
              ? EmojiWidget.svg(path: recipe.yields.svg, size: emojiSize)
              : Image.asset('assets/images/grimoire/queston_mark.png'),
        ),
        if (showUnreadIndicator)
          Positioned(
            top: -4,
            right: -4,
            child: UnreadBadge(
              color: crimsonColor,
              borderColor: midnightColor,
              showShadow: showUnreadShadow,
            ),
          ),
      ],
    );
  }
}
