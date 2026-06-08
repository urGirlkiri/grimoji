import 'dart:async';
import 'package:flutter/material.dart';
import 'package:grimoji/features/market/widgets/daily_reward.dart';
import 'package:grimoji/features/market/widgets/shop_item.dart';
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
                  _showSnackbar(
                    context,
                    "Cauldron Restored!",
                    isError: false,
                  );
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
                  _showSnackbar(
                    context,
                    "Cauldrons refilled!",
                    isError: false,
                  );
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
          ],
        ),
      ),
    );
  }
}
