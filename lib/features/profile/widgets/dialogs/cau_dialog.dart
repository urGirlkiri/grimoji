import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/cauldrons.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/features/profile/widgets/caul_regen_tim.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';
import 'package:provider/provider.dart';

class CauldronDialog extends StatelessWidget {
  const CauldronDialog({super.key});

  void _showSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError
            ? palette.crimson
            : palette.dusk,
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

  void _buyOne(BuildContext context) {
    final profile = context.read<ProfileController>();
    if (profile.spendDice(CauldronPrice.restoreOne)) {
      context.readAudio.playSfx(SfxType.purchase);
      profile.refillCauldrons();
      _showSnackbar(context, 'Cauldron restored!');
    } else {
      _showSnackbar(context, "Not enough dice!", isError: true);
    }
  }

  void _buyAll(BuildContext context) {
    final profile = context.read<ProfileController>();
    if (profile.spendDice(CauldronPrice.refillAll)) {
      context.readAudio.playSfx(SfxType.purchase);
      profile.refillCauldrons();
      _showSnackbar(context, 'All cauldrons refilled!');
    } else {
      _showSnackbar(context, "Not enough dice!", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;

    return Selector<ProfileController, ({int cauldrons, int dices})>(
      selector: (_, profile) =>
          (cauldrons: profile.cauldrons, dices: profile.dices),
      builder: (context, data, _) {
        final isFull = data.cauldrons >= 5;
        final hasDice = data.dices > 0;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: ScrollDialog(
            rightButton: const CorkScrewCloseButton(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        'assets/images/cauldron.png',
                        width: 250 * scale,
                        height: 250 * scale,
                        fit: BoxFit.contain,
                      ),
                      Positioned(
                        bottom: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: palette.slate,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: palette.twilight,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: palette.voidBlack,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            isFull ? "Full" : "${data.cauldrons}/5",
                            style: context.theme.textTheme.titleMedium
                                ?.copyWith(
                                  color: palette.trueWhite,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  fontSize: 24 * context.globalScale,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  if (!isFull) ...[
                    const CaulRegenTim(),
                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                      child: Column(
                        children: [
                          Text(
                            "Need more cauldrons?",
                            style: context.theme.textTheme.bodyMedium?.copyWith(
                              color: palette.moonlightSoft,
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (hasDice) ...[
                            _BuyButton(
                              label:
                                  '${CauldronPrice.restoreOneLabel}  •  ${CauldronPrice.restoreOne}',
                              cost: CauldronPrice.restoreOne,
                              dices: data.dices,
                              onTap: () => _buyOne(context),
                            ),
                            const SizedBox(height: 10),
                            _BuyButton(
                              label:
                                  '${CauldronPrice.refillAllLabel}  •  ${CauldronPrice.refillAll}',
                              cost: CauldronPrice.refillAll,
                              dices: data.dices,
                              onTap: () => _buyAll(context),
                            ),
                          ] else ...[
                            SizedBox(
                              width: double.infinity,
                              child: AnimatedButton(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  GoRouter.of(context).pushNamed(Routes.market);
                                },
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: palette.twilight,
                                    foregroundColor: palette.mist,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    elevation: 5,
                                  ),
                                  onPressed: null,
                                  icon: Image.asset(
                                    'assets/images/dice.png',
                                    width: 28,
                                    height: 28,
                                  ),
                                  label: Text(
                                    "Visit The Market",
                                    style: context.theme.textTheme.titleMedium
                                        ?.copyWith(color: palette.mist),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BuyButton extends StatelessWidget {
  const _BuyButton({
    required this.label,
    required this.cost,
    required this.dices,
    required this.onTap,
  });

  final String label;
  final int cost;
  final int dices;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canAfford = dices >= cost;
    
    return PillButton(
      text: label,
      leading: Image.asset('assets/images/dice.png', width: 22, height: 22),
      color: canAfford ? palette.twilight : palette.slate,
      textColor: canAfford ? palette.mist : palette.mist.withValues(alpha: 0.5),
      fullWidth: true,
      borderColor: canAfford ? palette.dusk : palette.slate,
      borderWidth: 2,
      onTap: canAfford ? onTap : () {},
      enableAnimation: canAfford,
    );
  }
}
