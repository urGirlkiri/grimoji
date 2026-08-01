import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/cauldron/game/state.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:provider/provider.dart';

class ScoreCard extends StatelessWidget {
  static const highScore = 20000;

  const ScoreCard({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final score = context.select<CauldronState, int>((s) => s.score);
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          palette.dusk.withValues(alpha: 0.15),
          palette.twilight,
        ),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: palette.slate.withValues(alpha: 0.1),
          width: 1,
        ),
        image: DecorationImage(
          image: const AssetImage('assets/images/goth_emo.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            palette.voidBlack.withValues(alpha: 0.05),
            BlendMode.dstATop,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: palette.voidBlack,
            offset: Offset(0, 6 * scale),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(score.toString(), style: context.theme.textTheme.bodyLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              EmojiWidget.svg(emoji: Emojis.moai, size: 20),
              const SizedBox(width: 3),
              Text(highScore.toString(), style: context.theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
