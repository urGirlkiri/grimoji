import 'package:flutter/material.dart';
import 'package:grimoji/config/cauldrons.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/market/widgets/daily_reward/index.dart';
import 'package:grimoji/features/market/widgets/powerups/index.dart';
import 'package:grimoji/features/market/widgets/powerups/item.dart';
import 'package:grimoji/utils/context_data.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  void playPurchaseSfx(BuildContext context) {
    context.readAudio.playSfx(SfxType.purchase);
  }

  void _showSnackbar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? context.palette.crimson
            : context.palette.dusk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: context.theme.textTheme.bodyMedium?.copyWith(
            color: context.palette.moonlight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    return Scaffold(
      backgroundColor: context.palette.midnight,
      body: Container(
        decoration: BoxDecoration(
          color: context.palette.midnight,
          image: DecorationImage(
            image: const AssetImage('assets/images/vertical_lines.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              context.palette.voidBlack.withValues(alpha: 0.009),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(24.0 * scale),
          physics: const BouncingScrollPhysics(),
          children: [
            GestureDetector(
              onDoubleTap: () {
                context.readProfile.addDice(1000);
              },
              child: Text(
                "Daily Offerings",
                style: context.theme.textTheme.titleMedium?.copyWith(
                  color: context.palette.mist,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(height: 16 * scale),
            const DailyRewardCard(),
            SizedBox(height: 36 * scale),
            Text(
              "Bazaar",
              style: context.theme.textTheme.titleMedium?.copyWith(
                color: context.palette.mist,
                fontSize: 18 * scale,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 16 * scale),
            ShopItemCard(
              title: "Restore Cauldron",
              description: "Instantly restore 1 Cauldron.",
              cost: CauldronPrice.restoreOne,
              iconPath: CauldronPrice.iconPath,
              onTap: () {
                final profile = context.readProfile;
                if (profile.spendDice(CauldronPrice.restoreOne)) {
                  playPurchaseSfx(context);
                  profile.refillCauldrons();
                  _showSnackbar(context, "Cauldron Restored!", isError: false);
                } else {
                  _showSnackbar(
                    context,
                    "You don't have enough magic for this yet!",
                    isError: true,
                  );
                }
              },
            ),
            SizedBox(height: 20 * scale),
            ShopItemCard(
              title: "Cauldron Refill",
              description: "Instantly restore all 5 Cauldrons.",
              cost: CauldronPrice.refillAll,
              iconPath: CauldronPrice.iconPath3,
              onTap: () {
                final profile = context.readProfile;
                if (profile.spendDice(CauldronPrice.refillAll)) {
                  playPurchaseSfx(context);
                  profile.refillCauldrons();
                  _showSnackbar(context, "Cauldrons refilled!", isError: false);
                } else {
                  _showSnackbar(
                    context,
                    "You don't have enough magic for this yet!",
                    isError: true,
                  );
                }
              },
            ),
            SizedBox(height: 40 * scale),
            PowerupSection(
              title: 'Boosters',
              subtitle: 'Equip before a level starts for a tactical advantage.',
              items: Powerup.prelevel,
            ),
            SizedBox(height: 40 * scale),
            PowerupSection(
              title: 'Powerups',
              subtitle: 'Have an extra edge during play.',
              items: Powerup.bottom,
            ),
            SizedBox(height: 40 * scale),
          ],
        ),
      ),
    );
  }
}
