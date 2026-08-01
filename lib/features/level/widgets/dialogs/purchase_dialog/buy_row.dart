import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class BuyRow extends StatelessWidget {
  const BuyRow({
    super.key,
    required this.boost,
    required this.qty,
    required this.profile,
    required this.onTap,
  });

  final Powerup boost;
  final int qty;
  final ProfileController profile;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final total = boost.price * qty;
    final canAfford = profile.dices >= total;

    return AnimatedButton(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 14 * scale,
          vertical: 12 * scale,
        ),
        decoration: BoxDecoration(
          color: canAfford
              ? palette.twilight
              : palette.midnight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(
            color: canAfford
                ? palette.dusk
                : palette.dusk.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: canAfford
              ? [
                  BoxShadow(
                    color: palette.voidBlack,
                    offset: Offset(0, 4 * scale),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            EmojiWidget(assetPath: boost.iconPath, size: 28 * scale),
            SizedBox(width: 8 * scale),
            Text(
              '×$qty',
              style: context.theme.textTheme.bodyLarge?.copyWith(
                color: canAfford
                    ? palette.moonlight
                    : palette.dusk,
                fontWeight: FontWeight.w900,
                fontSize: 16 * scale,
              ),
            ),
            const Spacer(),
            Image.asset(
              'assets/images/dice.png',
              width: 18 * scale,
              height: 18 * scale,
              color: canAfford ? null : palette.dusk,
            ),
            SizedBox(width: 6 * scale),
            Text(
              '$total',
              style: context.theme.textTheme.bodyLarge?.copyWith(
                color: canAfford
                    ? palette.moonlight
                    : palette.dusk,
                fontWeight: FontWeight.w900,
                fontSize: 16 * scale,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
