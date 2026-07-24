import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/profile/widgets/dialogs/notif_dialog/empty_message.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animated/corkscrew_close_btn.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:grimoji/widgets/custom/scroll_dialog.dart';
import 'package:grimoji/widgets/custom/unread_badge.dart';

class NotifDialog extends StatelessWidget {
  const NotifDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.readProfile;
    final canClaimDaily = profile.canClaimDaily();

    final scale = context.globalScale;
    final height = 50 * scale;

    return Dialog(
      insetPadding: const EdgeInsets.all(0),
      child: ScrollDialog(
        rightButton: const CorkScrewCloseButton(),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: canClaimDaily
              ? AnimatedButton(
                  onTap: () {
                    Navigator.of(context).pop();
                    GoRouter.of(context).goNamed(Routes.market);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: height,
                        child: const Center(child: UnreadBadge()),
                      ),
                      Image.asset(
                        'assets/images/dice.png',
                        width: 50 * scale,
                        height: height,
                      ),
                      SizedBox(width: 12 * scale),
                      SizedBox(
                        height: height,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Dice',
                              style: context.theme.textTheme.titleMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    height: 0,
                                  ),
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4,),
                            Text(
                              'Claim Your Free Dices',
                              style: context.theme.textTheme.titleSmall!
                                  .copyWith(
                                    letterSpacing: 0.5,
                                  ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const EmptyMessage(),
        ),
      ),
    );
  }
}
