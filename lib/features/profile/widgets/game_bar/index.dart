import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/profile/widgets/dialogs/cau_dialog.dart';
import 'package:grimoji/features/profile/widgets/dialogs/prof_dialog.dart';
import 'package:grimoji/features/profile/widgets/dialogs/notif_dialog.dart';
import 'package:grimoji/features/profile/widgets/game_bar/profile_avatar.dart';
import 'package:grimoji/features/profile/widgets/game_bar/resource_pill.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';

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
    final profile = context.watchProfile;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 105.0 * context.globalScale,
        child: Container(
          color: backgroundColor,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 90.0 * context.globalScale,
                decoration: BoxDecoration(
                  color: context.palette.midnight,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.palette.voidBlack,
                      offset: Offset(0, 6 * context.globalScale),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: context.palette.voidBlack.withValues(alpha: 0.3),
                      offset: Offset(0, 10 * context.globalScale),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20 * context.globalScale,
                left: 12 * context.globalScale,
                right: 12 * context.globalScale,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppIcon(
                      fileName: 'mail_inbox',
                      size: 30 * context.globalScale,
                      onTap: () => onNotifTap(context),
                    ),
                    const SizedBox(width: 8),
                    ResourcePill(
                      iconPath: 'assets/images/cauldron.png',
                      value: profile.cauldrons == 5 ? "Full" : profile.cauldrons.toString(),
                      onTap: () => onCauldronTap(context),
                    ),
                    ProfileAvatar(
                      avatar: profile.avatar,
                      onTap: () => onProfileTap(context),
                    ),
                    ResourcePill(
                      iconPath: 'assets/images/dice.png',
                      value: profile.dices.toString(),
                      onTap: () => GoRouter.of(context).goNamed(Routes.market),
                    ),
                    const SizedBox(width: 8),
                    AppIcon(
                      fileName: 'settings',
                      size: 30 * context.globalScale,
                      onTap: () => GoRouter.of(context).pushNamed(Routes.settings),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
