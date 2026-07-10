import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/features/profile/widgets/dialogs/cau_dialog.dart';
import 'package:grimoji/features/profile/widgets/dialogs/prof_dialog.dart';
import 'package:grimoji/features/profile/widgets/dialogs/notif_dialog.dart';
import 'package:grimoji/features/profile/widgets/game_bar/profile_avatar.dart';
import 'package:grimoji/features/profile/widgets/game_bar/resource_pill.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';
import 'package:grimoji/widgets/custom/plaque.dart';
import 'package:provider/provider.dart';

class GameBar extends StatelessWidget {
  final Color backgroundColor;
  const GameBar({super.key, this.backgroundColor = Colors.transparent});

  void onProfileTap(BuildContext context) {
    showAnimatedDialog(context, const ProfileDialog());
  }

  void onCauldronTap(BuildContext context) {
    showAnimatedDialog(context, const CauldronDialog());
  }

  void onNotifTap(BuildContext context) {
    showAnimatedDialog(context, const NotifDialog());
  }

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;

    return GamePlaque(
      backgroundColor: backgroundColor,
      pchild: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppIcon(
            fileName: 'mail_inbox',
            size: 30 * scale,
            onTap: () => onNotifTap(context),
          ),
          SizedBox(width: 8 * scale),
          Selector<ProfileController, String>(
            selector: (_, profile) =>
                profile.cauldrons >= 5 ? 'Full' : profile.cauldrons.toString(),
            builder: (context, cauldrons, _) => ResourcePill(
              iconPath: 'assets/images/cauldron.png',
              value: cauldrons,
              onTap: () => onCauldronTap(context),
            ),
          ),
          Selector<ProfileController, String>(
            selector: (_, profile) => profile.avatar,
            builder: (context, avatar, _) => AnimatedButton(
              onTap: () => onProfileTap(context),
              child: ProfileAvatar(avatar: avatar),
            ),
          ),
          Selector<ProfileController, int>(
            selector: (_, profile) => profile.dices,
            builder: (context, dices, _) => ResourcePill(
              iconPath: 'assets/images/dice.png',
              value: dices.toString(),
              onTap: () => GoRouter.of(context).goNamed(Routes.market),
            ),
          ),
          SizedBox(width: 8 * scale),
          AppIcon(
            fileName: 'settings',
            size: 30 * scale,
            onTap: () => GoRouter.of(context).pushNamed(Routes.settings),
          ),
        ],
      ),
    );
  }
}
