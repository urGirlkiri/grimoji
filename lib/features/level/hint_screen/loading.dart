import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        EmojiWidget.lottie(
          path: Emojis.package.lottie,
          useDropShadow: false,
          size: 120,
        ),
        const SizedBox(height: 20),
        Text(
          "Gathering ingredients...",
          style: GoogleFonts.caudex(color: palette.mist, fontSize: 24),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
