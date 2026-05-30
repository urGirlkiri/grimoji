import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    return Scaffold(
      backgroundColor: context.palette.midnight,
      body: ListView(
        padding: EdgeInsets.all(24.0 * scale),
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            "Daily Offerings",
            style: context.theme.textTheme.titleMedium?.copyWith(
              color: context.palette.mist,
              fontSize: 18 * scale,
            ),
          ),
          SizedBox(height: 16 * scale),
          _buildDailyReward(context, scale),

          SizedBox(height: 32 * scale),

          Text(
            "Bazaar",
            style: context.theme.textTheme.titleMedium?.copyWith(
              color: context.palette.mist,
              fontSize: 18 * scale,
            ),
          ),
          SizedBox(height: 16 * scale),

          _buildShopCard(
            context: context,
            scale: scale,
            title: "Cauldron Refill",
            description: "Instantly restore all 5  Cauldrons.",
            cost: 150,
            iconPath: 'assets/images/cauldron.png',
            onTap: () {
              final profile = context.readProfile;
              if (profile.spendDice(150)) {
                profile.refillCauldrons();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: context.palette.slate,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    content: Text(
                      "Cauldrons refilled!",
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: context.palette.trueWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: context.palette.crimson,
                    content: Text(
                      "You don't have enough magic for this yet!",
                      style: context.theme.textTheme.bodyMedium?.copyWith(
                        color: context.palette.trueWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyReward(BuildContext context, double scale) {
    final profile = context.watchProfile;
    final canClaim = profile.canClaimDaily();
    final timeUntil = profile.timeUntilNextDailyClaim();

    String buttonText;
    VoidCallback? onPressed;

    if (canClaim) {
      buttonText = "Claim";
      onPressed = () {
        profile.claimDailyReward();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: context.palette.slate,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Text(
              "+15 Dices Claimed!",
              style: context.theme.textTheme.bodyMedium?.copyWith(
                color: context.palette.trueWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      };
    } else {
      final hours = timeUntil.inHours;
      final minutes = timeUntil.inMinutes % 60;
      final seconds = timeUntil.inSeconds % 60;
      buttonText =
          "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
      onPressed = null;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.palette.twilight, context.palette.midnight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: canClaim ? context.palette.slate : context.palette.twilight,
          width: canClaim ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.palette.voidBlack.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.all(16 * scale),
      child: Row(
        children: [
          Image.asset(
            'assets/images/dice.png',
            width: 55 * scale,
            height: 55 * scale,
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Free Daily Dices",
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    color: context.palette.trueWhite,
                    fontSize: 16 * scale,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  canClaim
                      ? "+15 magical dices to spend in the bazaar."
                      : "Next claim available in $buttonText",
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    color: context.palette.mist,
                    fontSize: 12 * scale,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          SizedBox(
            width: 85 * scale,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: context.palette.mist,
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
              ),
              onPressed: onPressed,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  buttonText,
                  style: context.theme.textTheme.bodyLarge?.copyWith(
                    color: context.palette.moonlight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard({
    required BuildContext context,
    required double scale,
    required String title,
    required String description,
    required int cost,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.twilight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: context.palette.dusk, width: 1.5),
      ),
      padding: EdgeInsets.all(16 * scale),
      child: Row(
        children: [
          Image.asset(iconPath, width: 50 * scale, height: 50 * scale),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    color: context.palette.trueWhite,
                    fontSize: 16 * scale,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  description,
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    color: context.palette.mist,
                    fontSize: 12 * scale,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: context.palette.slate,
              padding: EdgeInsets.symmetric(horizontal: 12 * scale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * scale),
              ),
            ),
            onPressed: onTap,
            icon: Image.asset(
              'assets/images/dice.png',
              width: 18 * scale,
              height: 18 * scale,
            ),
            label: Text(
              cost.toString(),
              style: context.theme.textTheme.bodyLarge?.copyWith(
                color: context.palette.moonlight,
                fontSize: 16 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
