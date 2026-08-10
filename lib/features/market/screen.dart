import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/cauldrons.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/audio/sounds/sfx.dart';
import 'package:grimoji/features/market/scroll_controller.dart';
import 'package:grimoji/features/market/widgets/daily_reward/index.dart';
import 'package:grimoji/features/market/widgets/powerups/index.dart';
import 'package:grimoji/features/market/widgets/powerups/item.dart';
import 'package:grimoji/utils/context_data.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final GlobalKey _dailyRewardKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  String? _lastScrolledUri;
  MarketScrollController? _marketScroller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.readMarketScrollController;
    if (_marketScroller != controller) {
      _marketScroller?.removeListener(_scrollToDailyReward);
      _marketScroller = controller;
      _marketScroller?.addListener(_scrollToDailyReward);
    }

    final uri = GoRouterState.of(context).uri;
    if (uri.queryParameters['claim'] == 'dice' &&
        _lastScrolledUri != uri.toString()) {
      _lastScrolledUri = uri.toString();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToDailyReward();
      });
    }
  }

  @override
  void dispose() {
    _marketScroller?.removeListener(_scrollToDailyReward);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToDailyReward() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else if (_dailyRewardKey.currentContext != null) {
      Scrollable.ensureVisible(
        _dailyRewardKey.currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void playPurchaseSfx(BuildContext context) {
    context.readAudio.playSfx(Sfx.purchase);
  }

  void _showSnackbar(
    BuildContext context,
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? palette.crimson : palette.dusk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          message,
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
    final scale = context.globalScale;
    return Scaffold(
      backgroundColor: palette.midnight,
      body: Container(
        decoration: BoxDecoration(
          color: palette.midnight,
          image: DecorationImage(
            image: const AssetImage('assets/images/vertical_lines.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              palette.voidBlack.withValues(alpha: 0.009),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: ListView(
          controller: _scrollController,
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
                  color: palette.mist,
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            SizedBox(height: 16 * scale),
            DailyRewardCard(key: _dailyRewardKey),
            SizedBox(height: 36 * scale),
            Text(
              "Bazaar",
              style: context.theme.textTheme.titleMedium?.copyWith(
                color: palette.mist,
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
