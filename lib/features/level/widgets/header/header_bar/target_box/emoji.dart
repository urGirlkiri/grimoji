import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:provider/provider.dart';

class TargetEmoji extends StatelessWidget {
  const TargetEmoji({super.key});

  @override
  Widget build(BuildContext context) {
    final hasCombo = context.select<LevelState, bool>(
      (s) => s.gameState.hasTargetCombo,
    );
    final isPaused = context.select<LevelState, bool>((s) => s.isPaused);
    final targetIconKey = context.select<LevelState, GlobalKey>(
      (s) => s.targetIconKey,
    );
    final targetEmoji = context.select<LevelState, GameEmoji>(
      (s) => s.level.targetEmoji,
    );

    return hasCombo && !isPaused
        ? EmojiWidget.lottie(
            key: targetIconKey,
            path: targetEmoji.lottie,
            useDropShadow: true,
            size: 40,
            blurRadius: 4,
            shadowOffset: const Offset(0, 4),
            shadowColor: context.palette.midnight,
          )
        : EmojiWidget.svg(key: targetIconKey, path: targetEmoji.svg, size: 40);
  }
}