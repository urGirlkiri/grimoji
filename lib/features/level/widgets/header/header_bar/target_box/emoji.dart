import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:provider/provider.dart';

class TargetEmoji extends StatelessWidget {
  const TargetEmoji({super.key});

  @override
  Widget build(BuildContext context) {
    final isPaused = context.select<LevelState, bool>(
      (s) => s.gameState.isPaused,
    );
    final targetIconKey = context.select<LevelState, GlobalKey>(
      (s) => s.targetIconKey,
    );
    final targetEmoji = context.select<LevelState, GameEmoji>(
      (s) => s.level.targetEmoji,
    );
    final isCollecting = context.select<LevelState, bool>(
      (s) => s.gameState.hasTargetCombo,
    );

    return isCollecting && !isPaused
        ? EmojiWidget.lottie(
            key: targetIconKey,
            emoji: targetEmoji,
            useDropShadow: true,
            size: 40,
            blurRadius: 4,
            shadowOffset: const Offset(0, 4),
            shadowColor: palette.midnight,
          )
        : EmojiWidget.svg(key: targetIconKey, emoji: targetEmoji, size: 40);
  }
}
