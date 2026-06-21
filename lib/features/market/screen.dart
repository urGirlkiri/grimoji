import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/market/widgets/daily_reward/index.dart';
import 'package:grimoji/features/market/widgets/shop_item.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

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
            if (kDebugMode)
              Padding(
                padding: EdgeInsets.only(bottom: 16 * scale),
                child: PillButton(
                  text: 'Add +1000 Dice',
                  color: context.palette.crimson.withValues(alpha: 0.25),
                  textColor: context.palette.crimson,
                  borderWidth: 1,
                  fullWidth: true,
                  onTap: () {
                    context.readProfile.addDice(1000);
                    _showSnackbar(
                      context,
                      '+1000 dice',
                      isError: false,
                    );
                  },
                ),
              ),
            Text(
              "Daily Offerings",
              style: context.theme.textTheme.titleMedium?.copyWith(
                color: context.palette.mist,
                fontSize: 18 * scale,
                fontWeight: FontWeight.w900,
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
              cost: 30,
              iconPath: 'assets/images/cauldron.png',
              onTap: () {
                final profile = context.readProfile;
                if (profile.spendDice(30)) {
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
              cost: 150,
              iconPath: 'assets/images/cauldrons.png',
              onTap: () {
                final profile = context.readProfile;
                if (profile.spendDice(150)) {
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
            Text(
              "Boosters",
              style: context.theme.textTheme.titleMedium?.copyWith(
                color: context.palette.mist,
                fontSize: 18 * scale,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              "Equip before a level starts for a tactical advantage.",
              style: context.theme.textTheme.bodySmall?.copyWith(
                color: context.palette.slate,
                fontSize: 12 * scale,
              ),
            ),
            SizedBox(height: 16 * scale),
            ...Powerup.prelevel.map((boost) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12 * scale),
                child: Builder(
                  builder: (context) {
                    final profile = context.readProfile;
                    return ListenableBuilder(
                      listenable: profile,
                      builder: (context, _) {
                        final count = profile.getPowerupCount(boost.id);
                        return ShopItemCard(
                          title: boost.name,
                          description: boost.description,
                          cost: boost.price,
                          iconPath: boost.iconPath,
                          isEmoji: true,
                          amount: '×${boost.bundleAmount.toString()}',
                          ownedCount: count,
                          onTap: () {
                            if (profile.spendDice(boost.price)) {
                              profile.updatePowerupCount(boost.id, boost.bundleAmount);
                              _showSnackbar(
                                context,
                                "Got ${boost.bundleAmount.toString()}× ${boost.name}!",
                                isError: false,
                              );
                            } else {
                              _showSnackbar(
                                context,
                                "Need ${boost.price} dice for this boost!",
                                isError: true,
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              );
            }),
            SizedBox(height: 40 * scale),
          ],
        ),
      ),
    );
  }
}
