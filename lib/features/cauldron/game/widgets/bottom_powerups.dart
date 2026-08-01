import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/level/widgets/footer/powerup.dart';

class BottomPowerups extends StatelessWidget {
  const BottomPowerups({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: palette.twilight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      child: FittedBox(
        child: Row(
          children: [
            PowerupBtn(
              bgColor: palette.dusk,
              assetPath: Emojis.shakingFace.svg,
              onTap: () {},
            ),
            const SizedBox(width: 12),
            PowerupBtn(
              bgColor: palette.dusk,
              assetPath: Emojis.boomerang.svg,
              onTap: () {},
            ),
            const SizedBox(width: 12),
            PowerupBtn(
              bgColor: palette.dusk,
              assetPath: Emojis.testTube.svg,
              onTap: () {},
            ),
            const SizedBox(width: 12),
            PowerupBtn(
              bgColor: palette.dusk,
              assetPath: Emojis.flyingSaucer.svg,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
