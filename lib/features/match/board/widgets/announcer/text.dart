import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/app/theme/palette.dart';

class AnText extends StatelessWidget {
  const AnText({super.key, required this.phrase});

  final String phrase;

  @override
  Widget build(BuildContext context) {
    

    final glowColor =
        phrase.contains("Calamity") || phrase.contains("Catastrophic")
        ? palette.crimson
        : palette.twilight;

    final double baseFontSize = phrase.length > 18 ? 32.0 : 48.0;
    final double scaleFactor = baseFontSize / 20.0;

    final baseTextStyle = GoogleFonts.eagleLake(
      fontSize: baseFontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5 * scaleFactor,
      height: 1.1,
    );

    final edgePadding = EdgeInsets.only(
      bottom: 16.0 * scaleFactor,
      top: 8.0 * scaleFactor,
      left: 14.0 * scaleFactor,
      right: 14.0 * scaleFactor,
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: edgePadding,
            child: Text(
              phrase,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              style: baseTextStyle.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 10.0 * scaleFactor
                  ..color = glowColor,
                shadows: [
                  Shadow(blurRadius: 15 * scaleFactor, color: glowColor),
                  Shadow(blurRadius: 30 * scaleFactor, color: palette.midnight),
                ],
              ),
            ),
          ),

          Padding(
            padding: edgePadding,
            child: Text(
              phrase,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              style: baseTextStyle.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6.0 * scaleFactor
                  ..color = palette.midnight,
              ),
            ),
          ),

          Padding(
            padding: edgePadding,
            child: Text(
              phrase,
              textAlign: TextAlign.center,
              maxLines: 1,
              softWrap: false,
              style: baseTextStyle.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 2.0 * scaleFactor
                  ..color = palette.slate,
              ),
            ),
          ),

          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  palette.slate,
                  palette.moonlightSoft,
                  palette.midnight,
                ],
                stops: const [0.0, 0.45, 1.0],
              ).createShader(bounds);
            },
            child: Padding(
              padding: edgePadding,
              child: Text(
                phrase,
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
                style: baseTextStyle.copyWith(color: palette.slate),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
