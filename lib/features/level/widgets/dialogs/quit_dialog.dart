import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class QuitDialog extends StatelessWidget {
  final int level;

  const QuitDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(
        rightButton: const CorkScrewCloseButton(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            EmojiWidget.lottie(
              emoji: Emojis.cryingCatFace,
              useDropShadow: true,
              size: 70,
            ),
            const SizedBox(height: 16),
            Text(
              "Quit Level?",
              textAlign: TextAlign.center,
              style: GoogleFonts.eagleLake(
                color: palette.midnight,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Progress will be lost!",
              textAlign: TextAlign.center,
              style: GoogleFonts.eagleLake(
                color: palette.twilight,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
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
                    GoRouter.of(context).goNamed(
                      Routes.levelFail,
                      pathParameters: {'level': level.toString()},
                    );
                  },
                ),
                PillButton(
                  text: "Stay",
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
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
