import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:provider/provider.dart';

class TargetBox extends StatelessWidget {
  const TargetBox({super.key});

  @override
  Widget build(BuildContext context) {
    final levelState = context.watch<LevelState>();
    final hasCombo = levelState.gameState.hasTargetCombo;
    final isPaused = levelState.isPaused;
    final targetIconKey = levelState.targetIconKey;
    final targetEmoji = levelState.level.targetEmoji;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: ShapeDecoration(
        color: context.palette.dusk,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: ShapeDecoration(
              color: context.palette.slate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Target',
              style: TextStyle(color: context.palette.trueWhite, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          hasCombo && !isPaused
              ? EmojiWidget.lottie(
                  key: targetIconKey,
                  path: targetEmoji.lottie,
                  useDropShadow: true,
                  size: 40,
                  blurRadius: 4,
                  shadowOffset: const Offset(0, 4),
                  shadowColor: context.palette.midnight,
                )
              : EmojiWidget.svg(
                  key: targetIconKey,
                  path: targetEmoji.svg,
                  size: 40,
                ),
        ],
      ),
    );
  }
}
