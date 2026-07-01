import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/cauldrons.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/utils/context_data.dart';
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

  void _buyOne(BuildContext context) {
    final profile = context.read<ProfileController>();
    if (profile.spendDice(CauldronPrice.restoreOne)) {
      context.readAudio.playSfx(SfxType.purchase);
      profile.refillCauldrons();
      Navigator.of(context).pop();
      _showSnackbar(context, 'Cauldron restored!');
    } else {
      _showSnackbar(context, 'Not enough dice!', isError: true);
    }
  }

  void _buyAll(BuildContext context) {
    final profile = context.read<ProfileController>();
    if (profile.spendDice(CauldronPrice.refillAll)) {
      context.readAudio.playSfx(SfxType.purchase);
      profile.refillCauldrons();
      Navigator.of(context).pop();
      _showSnackbar(context, 'All cauldrons refilled!');
    } else {
      _showSnackbar(context, 'Not enough dice!', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;

    return Selector<ProfileController, int>(
      selector: (_, p) => p.dices,
      builder: (context, dices, _) {
        final hasDice = dices > 0;
        final palette = context.palette;

        return Center(
          child: ScrollDialog(
            scrollType: ScrollType.fullyOpenHorizontal,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 24 * scale,
                vertical: 20 * scale,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/cauldron_explosion.png',
                    width: 150 * scale,
                    height: 150 * scale,
                  ),
                  SizedBox(height: 10 * scale),
                  Text(
                    'No cauldrons left!',
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      color: palette.moonlight,
                      fontWeight: FontWeight.w900,
                      fontSize: 16 * scale,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    hasDice
                        ? 'Spend dice to restore them cauldron'
                        : 'You need a cauldron to play. Restore one at the Market.',
                    textAlign: TextAlign.center,
                    style: context.theme.textTheme.bodySmall?.copyWith(
                      color: palette.mist,
                      fontSize: 12 * scale,
                    ),
                  ),
                  SizedBox(height: 20 * scale),
                  if (hasDice) ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                      child: Column(
                        children: [
                          PillButton(
                            text:
                                '${CauldronPrice.restoreOneLabel}  •  ${CauldronPrice.restoreOne}',
                            leading: Image.asset(
                              'assets/images/dice.png',
                              width: 20 * scale,
                              height: 20 * scale,
                            ),
                            color: dices >= CauldronPrice.restoreOne
                                ? palette.twilight
                                : palette.slate,
                            textColor: dices >= CauldronPrice.restoreOne
                                ? palette.mist
                                : palette.mist.withValues(alpha: 0.5),
                            fullWidth: true,
                            fontSize: 13 * scale,
                            enableAnimation: dices >= CauldronPrice.restoreOne,
                            onTap: dices >= CauldronPrice.restoreOne
                                ? () => _buyOne(context)
                                : () {},
                          ),
                          SizedBox(height: 8 * scale),
                          PillButton(
                            text:
                                '${CauldronPrice.refillAllLabel}  •  ${CauldronPrice.refillAll}',
                            leading: Image.asset(
                              'assets/images/dice.png',
                              width: 20 * scale,
                              height: 20 * scale,
                            ),
                            color: dices >= CauldronPrice.refillAll
                                ? palette.twilight
                                : palette.slate,
                            textColor: dices >= CauldronPrice.refillAll
                                ? palette.mist
                                : palette.mist.withValues(alpha: 0.5),
                            fullWidth: true,
                            fontSize: 13 * scale,
                            enableAnimation: dices >= CauldronPrice.refillAll,
                            onTap: dices >= CauldronPrice.refillAll
                                ? () => _buyAll(context)
                                : () {},
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    PillButton(
                      enableAnimation: false,
                      color: palette.slate,
                      fullWidth: true,
                      fontSize: 12 * scale,
                      text: 'Cancel',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: PillButton(
                              enableAnimation: false,
                              color: palette.slate,
                              fullWidth: false,
                              fontSize: 12 * scale,
                              text: 'Cancel',
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ),
                          SizedBox(width: 10 * scale),
                          Expanded(
                            child: PillButton(
                              color: palette.twilight,
                              fullWidth: false,
                              text: 'Market',
                              fontSize: 12 * scale,
                              onTap: () {
                                Navigator.of(context).pop();
                                GoRouter.of(context).goNamed(Routes.market);
                              },
                            ),
                          ),
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
