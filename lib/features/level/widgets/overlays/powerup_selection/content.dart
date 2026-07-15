import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:grimoji/widgets/custom/plaque.dart';
import 'package:provider/provider.dart';

class Content extends StatelessWidget {
  final bool isAnimating;

  const Content({super.key, this.isAnimating = false});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selectedPowerup = context.watch<LevelState>().selectedPowerup;
    final topPadding = MediaQuery.paddingOf(context).top;

    return GestureDetector(
      onTap: isAnimating
          ? null
          : () => context.read<LevelState>().cancelPowerupSelection(),
      child: GamePlaque(
        height: 210 + topPadding,
        child: Padding(
          padding: EdgeInsets.only(
            left: 95,
            right: 95,
            top: topPadding,
            bottom: 15,
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
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: palette.trueWhite,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap any emoji to use powerup',
                  textAlign: TextAlign.center,
                  style: context.theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: palette.moonlight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
