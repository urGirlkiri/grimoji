import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/app/theme/palette.dart';
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
    barrierColor: palette.voidBlack.withValues(alpha: .85),
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
      barrierColor: palette.voidBlack.withValues(alpha: .6),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLarge = context.isLargeScreen;
        final dialogWidth = isLarge
            ? 550.0
            : (constraints.maxWidth * 0.9).clamp(300.0, 550.0);
        final dialogHeight = (dialogWidth * (isLarge ? 1.32 : 1.5)).clamp(
          180.0,
          constraints.maxHeight,
        );
        final ropeHeight = (constraints.maxHeight - dialogHeight) +80 ;

        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: CustomPaint(
                size: Size(5, ropeHeight),
                painter: const RopePainter(),
              ),
            ),
            Center(
              child: ScrollDialog(
                scrollType: ScrollType.fullyOpenHorizontal,
                maxHeight: constraints.maxHeight,
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
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 1.0 * scale,
                              ),
                              child: Row(
                                children: [
                                  BalancePill(dices: profile.dices),
                                  Expanded(
                                    child: Center(
                                      child: SizedBox(
                                        width: starSize,
                                        height: starSize,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CustomPaint(
                                              size: Size(starSize, starSize),
                                              painter: StarPainter(
                                                color: palette.twilight,
                                                borderColor:
                                                    palette.dusk,
                                              ),
                                            ),
                                            EmojiWidget(
                                              assetPath:
                                                  boost.lottiePath ??
                                                  boost.iconPath,
                                              size: 58 * scale,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 60 * scale),
                                ],
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
                        padding: EdgeInsets.symmetric(horizontal: 24.0 * scale),
                        child: Text(
                          boost.description,
                          textAlign: TextAlign.center,
                          style: context.theme.textTheme.bodyMedium?.copyWith(
                            color: palette.mist,
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
        );
      },
    );
  }
}
