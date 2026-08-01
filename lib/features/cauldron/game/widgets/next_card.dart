import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class NextCard extends StatelessWidget {
  const NextCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    
      decoration: ShapeDecoration(
        color: palette.dusk.withValues(alpha: .8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            width: 2,
            color: palette.magicCyan.withValues(alpha: .5),
          ),
        ),
      ),
      child: Row(
        children: [
          Text("Next", style: context.theme.textTheme.titleSmall),
          const SizedBox(width: 6),
          EmojiWidget.svg(emoji: Emojis.heart, size: 15),
        ],
      ),
    );
  }
}
