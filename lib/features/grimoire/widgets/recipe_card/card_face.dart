import 'package:flutter/material.dart';
import 'package:grimoji/features/alchemy/recipes/models/recipe.dart';
import 'package:grimoji/features/grimoire/layout.dart';
import 'package:grimoji/features/grimoire/widgets/recipe_card/unread_badge.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:provider/provider.dart';

class CardFace extends StatelessWidget {
  final Recipe recipe;
  final bool showEmoji;
  final bool showUnreadIndicator;
  final bool showUnreadShadow;
  final Color crimsonColor;
  final Color midnightColor;

  const CardFace({
    super.key,
    required this.recipe,
    required this.showEmoji,
    required this.showUnreadIndicator,
    required this.crimsonColor,
    required this.midnightColor,
    this.showUnreadShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final layout = context.read<Layout>();

    final double dpr = MediaQuery.devicePixelRatioOf(context);

    const double cardWidth = 487.0;
    const double cardHeight = 700.0;

    final int cachedWidth = (cardWidth * dpr).round();
    final int cachedHeight = (cardHeight * dpr).round();

    final int iconCacheSize = (layout.emojiSize * dpr).round();

    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: const EdgeInsets.all(2.0),
          child: Image.asset(
            'assets/images/grimoire/card-frame.png',
            fit: BoxFit.fill,
            cacheWidth: cachedWidth,
            cacheHeight: cachedHeight,
            filterQuality: FilterQuality.high,
          ),
        ),
        Center(
          child: showEmoji
              ? EmojiWidget.svg(emoji: recipe.yields, size: layout.emojiSize)
              : Image.asset(
                  'assets/images/grimoire/queston_mark.png',
                  cacheWidth: iconCacheSize,
                  cacheHeight: iconCacheSize,
                  filterQuality: FilterQuality.high,
                ),
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
