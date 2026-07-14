import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:provider/provider.dart';

class Content extends StatelessWidget {
  final bool isAnimating;

  const Content({super.key, this.isAnimating = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selectedPowerup = context.watch<LevelState>().selectedPowerup;

    return GestureDetector(
      onTap: isAnimating
          ? null
          : () => context.read<LevelState>().cancelPowerupSelection(),
      child: Container(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.only(
            left: 95,
            right: 95,
            top: 20,
            bottom: 20,
          ),
          decoration: BoxDecoration(
            color: palette.slate,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: palette.voidBlack.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selectedPowerup != null && !isAnimating)
                  EmojiWidget.svg(
                    key: context.read<LevelState>().powerupIconKey,
                    path: selectedPowerup.iconPath,
                    size: 80,
                  ),
                const SizedBox(height: 16),
                Text(
                  'Select an emoji',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: palette.voidBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap any emoji to use powerup',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: palette.voidBlack),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
