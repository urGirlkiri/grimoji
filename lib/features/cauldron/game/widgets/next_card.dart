import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/cauldron/game/state.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:provider/provider.dart';

class NextCard extends StatelessWidget {
  const NextCard({super.key});

  @override
  Widget build(BuildContext context) {
    final nextEmoji = context.select<CauldronState, GameEmoji>(
      (s) => s.nextEmoji,
    );
    return EmojiWidget.svg(emoji: nextEmoji, size: 50 * context.globalScale);
  }
}
