import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/widgets/game/powerup_btn.dart';
import 'package:grimoji/utils/context_data.dart';

class BottomPowerups extends StatelessWidget {
  const BottomPowerups({super.key});

  void _showSnackbar(BuildContext context) {
    final scale = context.globalScale;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: palette.dusk,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(
          horizontal: 24 * scale,
          vertical: 125 * scale,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          'Coming Soon',
          textAlign: TextAlign.center,
          style: context.theme.textTheme.bodyMedium?.copyWith(
            color: palette.moonlight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: palette.twilight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: FittedBox(
        child: Row(
          children: [
            PowerupBtn(
              bgColor: palette.dusk,
              assetPath: Emojis.shakingFace.svg,
              onTap: () {
                _showSnackbar(context);
              },
            ),
            const SizedBox(width: 12),
            PowerupBtn(
              bgColor: palette.dusk,
              assetPath: Emojis.boxingGlove.svg,
              onTap: () {
                _showSnackbar(context);
              },
            ),
            const SizedBox(width: 12),
            PowerupBtn(
              bgColor: palette.dusk,
              assetPath: Emojis.up.svg,
              onTap: () {
                _showSnackbar(context);
              },
            ),
            const SizedBox(width: 12),
            PowerupBtn(
              bgColor: palette.dusk,
              assetPath: Emojis.collision.svg,
              onTap: () {
                _showSnackbar(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
