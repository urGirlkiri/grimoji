import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mojingo/features/game/logic/levels.dart';
import 'package:mojingo/widgets/scroll_dialog.dart';
import 'package:provider/provider.dart';

import 'package:mojingo/config/audio/audio_controller.dart';
import 'package:mojingo/config/audio/sounds.dart';
import 'package:mojingo/config/palette.dart';

import 'package:lottie/lottie.dart' hide DropShadow;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:drop_shadow/drop_shadow.dart';

class LevelStartDialog extends StatelessWidget {
  final GameLevel level;

  const LevelStartDialog({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ScrollDialog(
        closeButton: GestureDetector(
          onTap: () {
            context.read<AudioController>().playSfx(SfxType.buttonTap);
            Navigator.of(context).pop();
          },
          child: Container(
            decoration: BoxDecoration(
              color: palette.twilight,
              shape: BoxShape.circle,
              border: Border.all(color: palette.mist, width: 3),
              boxShadow: [
                BoxShadow(
                  color: palette.voidBlack.withValues(alpha: 0.5),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.close, color: palette.trueWhite, size: 48),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Level ${level.number}",
              style: GoogleFonts.eagleLake(
                color: palette.midnight,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildTargetEmoji(level.targetEmoji.lottie),

            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                context.read<AudioController>().playSfx(SfxType.buttonTap);
                Navigator.of(context).pop();
                GoRouter.of(context).replace('/play/hint/${level.number}');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: palette.twilight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: palette.voidBlack, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: palette.voidBlack.withValues(alpha: 0.5),
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  "MIX IT",
                  style: GoogleFonts.eagleLake(
                    fontSize: 24,
                    color: palette.mist,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetEmoji(String assetPath) {
    const double heroSize = 120.0;

    if (assetPath.endsWith('.json')) {
      return DropShadow(
        blurRadius: 8,
        offset: const Offset(0, 6),
        color: const Color(0x660E0E12),
        child: Lottie.asset(
          assetPath,
          width: heroSize,
          height: heroSize,
          fit: BoxFit.contain,
        ),
      );
    } else if (assetPath.endsWith('.svg')) {
      return DropShadow(
        blurRadius: 8,
        offset: const Offset(0, 6),
        color: const Color(0x660E0E12),
        child: SvgPicture.asset(
          assetPath,
          width: heroSize,
          height: heroSize,
          fit: BoxFit.contain,
        ),
      );
    } else {
      return Text(assetPath, style: const TextStyle(fontSize: 80));
    }
  }
}
