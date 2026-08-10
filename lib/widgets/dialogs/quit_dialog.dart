import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class QuitDialog extends StatelessWidget {
  final VoidCallback onQuit;
  final VoidCallback onStay;

  const QuitDialog({super.key, required this.onQuit, required this.onStay});

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;
    final isLarge = screenWidth > 400;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(
        rightButton: CorkScrewCloseButton(
          onTap: () {
            Navigator.of(context).pop();
            onStay();
          },
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              EmojiWidget.lottie(
                emoji: Emojis.cryingCatFace,
                useDropShadow: true,
                size: isLarge ? 100 : 70,
              ),
              const SizedBox(height: 16),
              Text(
                "Quit Level?",
                textAlign: TextAlign.center,
                style: GoogleFonts.eagleLake(
                  color: palette.midnight,
                  fontSize: isLarge ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Progress will be lost!",
                textAlign: TextAlign.center,
                style: GoogleFonts.eagleLake(
                  color: palette.twilight,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(height: isLarge ? 32 : 16),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isLarge ? 20 : 16,
                      vertical: isLarge ? 12 : 10,
                    ),
                    borderRadius: 20,
                    borderWidth: 3,
                    onTap: () {
                      Navigator.of(context).pop();
                      onQuit();
                    },
                  ),
                  PillButton(
                    text: "Stay",
                    color: palette.twilight,
                    textColor: palette.mist,
                    fullWidth: false,
                    padding: EdgeInsets.symmetric(
                      horizontal: isLarge ? 20 : 16,
                      vertical: isLarge ? 12 : 10,
                    ),
                    borderRadius: 20,
                    borderColor: palette.twilight,
                    borderWidth: 3,
                    onTap: () {
                      Navigator.of(context).pop();
                      onStay();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
