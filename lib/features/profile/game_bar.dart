import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/config/routes.dart';
import 'package:provider/provider.dart';

class GameBar extends StatelessWidget implements PreferredSizeWidget {
  final int cauldronCount = 5;
  final int currencyCount = 0;

  const GameBar({super.key});

  void onNotifTap() {}

  void onProfileTap() {}

  void onSettingsTap() {}

  void onCauldronTap() {}
  
  Widget _buildAppIcon({
    required String iconPath,
    required Palette palette,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(iconPath, width: 45, height: 45),
    );
  }

  Widget _buildResourcePill({
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
                _buildAppIcon(
                  iconPath: 'assets/icons/app/mail_inbox.png',
                  palette: palette,
                  onTap: onNotifTap,
                ),
                const SizedBox(width: 8),
                _buildResourcePill(
                  iconPath: 'assets/images/cauldron.png',
                  value: cauldronCount == 5 ? "Full" : cauldronCount.toString(),
                  palette: palette,
                  onTap: onCauldronTap
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
                        image: const DecorationImage(
                          image: AssetImage('assets/avatars/cyber_goth.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildResourcePill(
                  iconPath: 'assets/images/dice.png',
                  value: currencyCount.toString(),
                  palette: palette,
                  onTap: () => GoRouter.of(context).goNamed(Routes.market)
                ),
                const SizedBox(width: 8),
                _buildAppIcon(
                  iconPath: 'assets/icons/app/settings.png',
                  palette: palette,
                  onTap: onNotifTap,
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