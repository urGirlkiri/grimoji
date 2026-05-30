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
    return Scaffold(
      backgroundColor: context.palette.midnight,

      body: ListView(
        padding: EdgeInsets.all(24.0 * context.globalScale),
        physics: const BouncingScrollPhysics(),
        children: [
          Text(
            "Daily Offerings",
            style: context.theme.textTheme.titleMedium?.copyWith(
              color: context.palette.mist,
              fontSize: 18 * context.globalScale,
            ),
          ),
          const SizedBox(height: 16),
          _buildDailyReward(context),

          const SizedBox(height: 32),

          Text(
            "Bazaar",
            style: context.theme.textTheme.titleMedium?.copyWith(
              color: context.palette.mist,
              fontSize: 18 * context.globalScale,
            ),
          ),
          const SizedBox(height: 16),

          _buildShopCard(
            context: context,
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

  Widget _buildDailyReward(BuildContext context) {
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
      buttonText = "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
      onPressed = null;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.palette.twilight, context.palette.midnight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.slate, width: 2),
        boxShadow: [
          BoxShadow(
            color: context.palette.voidBlack.withValues(alpha: 0.6),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Image.asset('assets/images/dice.png', width: 65, height: 65),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Free Daily Dices",
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    color: context.palette.trueWhite,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  canClaim
                      ? "+15 magical dices to spend in the bazaar."
                      : "Next claim available in $buttonText",
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    color: context.palette.mist,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.palette.mist,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onPressed,
            child: Text(
              buttonText,
              style: context.theme.textTheme.bodyLarge?.copyWith(
                color: context.palette.moonlight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopCard({
    required BuildContext context,
    required String title,
    required String description,
    required int cost,
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.palette.twilight.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.palette.dusk, width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Image.asset(iconPath, width: 55, height: 55),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.theme.textTheme.titleMedium?.copyWith(
                    color: context.palette.trueWhite,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: context.theme.textTheme.bodySmall?.copyWith(
                    color: context.palette.mist,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: context.palette.slate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onTap,
            icon: Image.asset('assets/images/dice.png', width: 20, height: 20),
            label: Text(
              cost.toString(),
              style: context.theme.textTheme.bodyLarge?.copyWith(
                color: context.palette.moonlight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
