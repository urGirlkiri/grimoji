import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/level/widgets/dialogs/purchase_dialog/balance_pill.dart';
import 'package:grimoji/features/level/widgets/dialogs/purchase_dialog/buy_row.dart';
import 'package:grimoji/features/level/widgets/dialogs/purchase_dialog/insufficient.dart';
import 'package:grimoji/widgets/painters/rope.dart';
import 'package:grimoji/widgets/painters/star.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';
import 'package:provider/provider.dart';

Future<bool?> showBoostPurchase(BuildContext context, Powerup boost) async {
  final result = await showGeneralDialog<bool?>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: context.palette.voidBlack.withValues(alpha: .85),
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _PurchaseDialog(boost: boost);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1.2),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
  return result;
}

class _PurchaseDialog extends StatelessWidget {
  const _PurchaseDialog({required this.boost});

  final Powerup boost;

  Future<void> _onBuy(BuildContext context, int qty) async {
    final profile = context.read<ProfileController>();
    final total = boost.price * qty;

    if (profile.spendDice(total)) {
      profile.updatePowerupCount(boost.id, qty);
      context.readAudio.playSfx(SfxType.purchase);
      Navigator.of(context).pop(true);
    } else {
      final goToMarket = await showInsufficiensAlert(context, total);
      if (goToMarket && context.mounted) {
        Navigator.of(context).pop(null);
        GoRouter.of(context).goNamed(Routes.market);
      }
    }
  }

  Future<bool> showInsufficiensAlert(BuildContext context, int needed) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: context.palette.voidBlack.withValues(alpha: .6),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (ctx, animation, _) => InsufficientAlert(needed: needed),
      transitionBuilder: (ctx, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return ScaleTransition(scale: curved, child: child);
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final starSize = 110 * scale;
    final profile = context.read<ProfileController>();

    return Align(
      alignment: Alignment.topCenter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -50,
            child: CustomPaint(
              size: const Size(5, 500),
              painter: RopePainter(),
            ),
          ),
          Positioned(
            top: 200,
            child: ScrollDialog(
              scrollType: ScrollType.fullyOpenHorizontal,
              rightButton: CorkScrewCloseButton(
                onTap: () => Navigator.of(context).pop(false),
              ),
              padding: const EdgeInsets.all(0),
              child: ListenableBuilder(
                listenable: profile,
                builder: (context, _) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 50),
                    Padding(
                      padding: EdgeInsets.all(8 * scale),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 25,
                            top: 10,
                            child: BalancePill(dices: profile.dices),
                          ),
                          Center(
                            child: SizedBox(
                              width: starSize,
                              height: starSize,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CustomPaint(
                                    size: Size(starSize, starSize),
                                    painter: StarPainter(
                                      color: context.palette.twilight,
                                      borderColor: context.palette.dusk,
                                    ),
                                  ),
                                  EmojiWidget.svg(
                                    path: boost.iconPath,
                                    size: 58 * scale,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      boost.name,
                      textAlign: TextAlign.center,
                      style: context.theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.0 * scale),
                      child: Text(
                        boost.description,
                        textAlign: TextAlign.center,
                        style: context.theme.textTheme.bodyMedium?.copyWith(
                          color: context.palette.mist,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50.0),
                      child: Column(
                        children: [
                          BuyRow(
                            boost: boost,
                            qty: 1,
                            profile: profile,
                            onTap: () => _onBuy(context, 1),
                          ),
                          const SizedBox(height: 10),
                          BuyRow(
                            boost: boost,
                            qty: boost.bundleAmount,
                            profile: profile,
                            onTap: () => _onBuy(context, boost.bundleAmount),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
