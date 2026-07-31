import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final palette = context.palette;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        EmojiWidget.lottie(
          emoji: Emojis.package,
          useDropShadow: false,
          size: 120 * scale,
        ),
        SizedBox(height: 20 * scale),
        Text(
          "Gathering ingredients...",
          style: GoogleFonts.caudex(color: palette.mist, fontSize: 24 * scale),
        ),
      ],
    );
  }
}
