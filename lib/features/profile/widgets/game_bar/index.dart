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
    final topPadding = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: (105.0 * scale) + topPadding,
      child: Container(
        color: backgroundColor,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: (90.0 * scale) + topPadding,
              decoration: BoxDecoration(
                color: context.palette.midnight,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.palette.voidBlack,
                    offset: Offset(0, 6 * scale),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: context.palette.voidBlack.withValues(alpha: 0.3),
                    offset: Offset(0, 10 * scale),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
                image: DecorationImage(
                  image: const AssetImage('assets/images/vertical_lines.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    context.palette.midnight.withValues(alpha: 0.069),
                    BlendMode.dstATop,
                  ),
                ),
              ),
            ),
            Positioned(
              top: (20 * scale) + topPadding,
              left: 12 * scale,
              right: 12 * scale,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppIcon(
                    fileName: 'mail_inbox',
                    size: 30 * scale,
                    onTap: () => onNotifTap(context),
                  ),
                  const SizedBox(width: 8),
                  Selector<ProfileController, String>(
                    selector: (_, profile) => profile.cauldrons >= 5
                        ? 'Full'
                        : profile.cauldrons.toString(),
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
                  const SizedBox(width: 8),
                  AppIcon(
                    fileName: 'settings',
                    size: 30 * scale,
                    onTap: () =>
                        GoRouter.of(context).pushNamed(Routes.settings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
