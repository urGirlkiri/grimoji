import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/widgets/app_icon.dart';
import 'package:provider/provider.dart';

class GameBar extends StatelessWidget implements PreferredSizeWidget {
  const GameBar({super.key});

  void onNotifTap() {}

  void onProfileTap() {}

  void onSettingsTap() {}

  void onCauldronTap() {}

  Widget _buildResourcePill({
    required BuildContext context,
    required String iconPath,
    required String value,
    required Palette palette,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          height: 55,
          child: Stack(
            alignment: Alignment.centerLeft,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 20,
                right: 0,
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: palette.slate,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: palette.slate.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: palette.voidBlack,
                        offset: const Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(left: 20, right: 8),
                  child: Text(
                    value,
                    style: TextStyle(
                      color: palette.twilight,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'EagleLake',
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Positioned(
                left: 2,
                child: Image.asset(
                  iconPath,
                  width: 45,
                  height: 45,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final profile = context.watch<ProfileController>();

    return SizedBox(
      height: preferredSize.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 80.0,
            decoration: BoxDecoration(
              color: palette.midnight,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: palette.voidBlack,
                  offset: const Offset(0, 6),
                  blurRadius: 0,
                ),
                BoxShadow(
                  color: palette.voidBlack.withValues(alpha: 0.3),
                  offset: const Offset(0, 10),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          Positioned(
            top: 15,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppIcon(fileName: 'mail_inbox', size: 45, onTap: onNotifTap),
                const SizedBox(width: 8),
                _buildResourcePill(
                  context: context,
                  iconPath: 'assets/images/cauldron.png',
                  value: profile.cauldrons == 5
                      ? "Full"
                      : profile.cauldrons.toString(),
                  palette: palette,
                  onTap: onCauldronTap,
                ),
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: GestureDetector(
                    onTap: onProfileTap,
                    child: Container(
                      width: 75,
                      height: 80,
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.twilight, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: palette.slate.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: palette.midnight,
                            offset: const Offset(0, 4),
                            blurRadius: 0,
                          ),
                        ],
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/avatars/${profile.avatar}.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildResourcePill(
                  context: context,
                  iconPath: 'assets/images/dice.png',
                  value: profile.dices.toString(),
                  palette: palette,
                  onTap: () => GoRouter.of(context).goNamed(Routes.market),
                ),
                const SizedBox(width: 8),
                AppIcon(
                  fileName: 'settings',
                  size: 45,
                  onTap: () => GoRouter.of(context).pushNamed(Routes.settings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(105.0);
}
