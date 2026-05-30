import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/profile/widgets/caul_regen_tim.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class CauldronDialog extends StatelessWidget {
  const CauldronDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final cauldrons = context.watchProfile.cauldrons;
    final isFull = cauldrons >= 5;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ScrollDialog(
        rightButton: const CorkScrewCloseButton(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Your Cauldrons",
                style: context.theme.textTheme.headlineMedium?.copyWith(
                  color: context.palette.moonlight,
                  shadows: [
                    Shadow(
                      color: context.palette.voidBlack,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Image.asset(
                    'assets/images/cauldron.png',
                    width: 150 * context.globalScale,
                    height: 150 * context.globalScale,
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
                        color: context.palette.slate,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: context.palette.twilight,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.palette.voidBlack,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        isFull ? "Full" : "$cauldrons/5",
                        style: context.theme.textTheme.titleMedium?.copyWith(
                          color: context.palette.trueWhite,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
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
                          color: context.palette.moonlightSoft,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: context.palette.dusk,
                            foregroundColor: context.palette.moonlight,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          onPressed: () {
                            context.pop();
                            GoRouter.of(context).pushNamed(Routes.market);
                          },
                          icon: Image.asset(
                            'assets/images/dice.png',
                            width: 28,
                            height: 28,
                          ),
                          label: const Text("Visit The Market"),
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
  }
}