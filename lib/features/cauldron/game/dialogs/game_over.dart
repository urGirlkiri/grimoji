import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class GameOverDialog extends StatelessWidget {
  final int score;
  final VoidCallback onRetry;
  final VoidCallback onQuit;

  const GameOverDialog({
    super.key,
    required this.score,
    required this.onRetry,
    required this.onQuit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            EmojiWidget.lottie(
              emoji: Emojis.cryingCatFace,
              useDropShadow: true,
              size: 100,
            ),
            const SizedBox(height: 16),
            Text(
              "Game Over",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 12),
            Text(
              "Score: $score",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                PillButton(
                  text: "Retry",
                  color: palette.twilight,
                  textColor: palette.mist,
                  fullWidth: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  borderRadius: 20,
                  borderColor: palette.twilight,
                  borderWidth: 3,
                  onTap: () {
                    Navigator.of(context).pop();
                    onRetry();
                  },
                ),
                PillButton(
                  text: "Quit",
                  color: palette.crimson,
                  textColor: palette.trueWhite,
                  fullWidth: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  borderRadius: 20,
                  borderWidth: 3,
                  onTap: () {
                    Navigator.of(context).pop();
                    onQuit();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
