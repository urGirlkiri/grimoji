import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class CauldronDialog extends StatelessWidget {
  const CauldronDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(
        rightButton: const CorkScrewCloseButton(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/cauldron_explosion.png'),
            const SizedBox(height: 16),

            Text(
              "You have destroyed all the cauldrons!\n",
              textAlign: TextAlign.center,
              style: GoogleFonts.eagleLake(
                color: palette.twilight,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: SizedBox(
                width: double.infinity,
                child: AnimatedButton(
                  onTap: () {
                    Navigator.of(context).pop();
                    GoRouter.of(context).goNamed(Routes.market);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: palette.twilight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: palette.slate.withValues(alpha: 0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: palette.voidBlack,
                          offset: const Offset(0, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/dice.png',
                          width: 28,
                          height: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Visit The Market",
                          style: context.theme.textTheme.titleMedium?.copyWith(
                            color: palette.mist,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
