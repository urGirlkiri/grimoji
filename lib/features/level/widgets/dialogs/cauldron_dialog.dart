import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';

class CauldronDialog extends StatelessWidget {
  const CauldronDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.all(0),
      child: ScrollDialog(
        rightButton: CorkScrewCloseButton(),
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
              padding: const EdgeInsets.only(left: 48.0, right: 48.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: context.palette.twilight,
                    foregroundColor: context.palette.mist,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    GoRouter.of(context).goNamed(Routes.market);
                  },
                  icon: Image.asset(
                    'assets/images/dice.png',
                    width: 28,
                    height: 28,
                  ),
                  label: Text(
                    "Visit The Market",
                    style: context.theme.textTheme.titleMedium?.copyWith(
                      color: context.palette.mist,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
