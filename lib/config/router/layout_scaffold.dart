import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/features/audio/sounds.dart';
import 'package:grimoji/features/profile/widgets/game_bar.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/config/global_keys.dart';
import 'package:grimoji/config/router/routes.dart';

class LayoutScaffold extends StatelessWidget {
  const LayoutScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isLarge = context.isLargeScreen;

    final currentPath = GoRouterState.of(context).uri.path;
    final isMap = currentPath.startsWith(Routes.mapRoute);

    final double navHeight = isLarge ? 120.0 : 85.0;

    final double iconBaseSize = isLarge ? 100.0 : 60.0;
    final double iconSelectedSize = isLarge ? 120.0 : 80.0;

    return Scaffold(
      body: Column(
        children: [
          GameBar(backgroundColor: isMap ? Color(0xFF48484f) : palette.midnight),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: Container(
        height: navHeight,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: palette.twilight.withValues(alpha: 0.25),
              width: 2.0,
            ),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              palette.voidBlack.withValues(alpha: 0.8),
              palette.midnight,
              palette.midnight,
            ],
            stops: const [0.0, 0.2, 1.0],
          ),
        ),
        child: RepaintBoundary(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: destinations.asMap().entries.map((entry) {
              final int index = entry.key;
              final Destination dest = entry.value;
              final bool isSelected = navigationShell.currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  key: index ==
                          destinations.indexWhere(
                            (dest) => dest.label.toLowerCase().contains('grim'),
                          )
                      ? AppKeys.grimoireNavKey
                      : null,
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    context.readAudio.playSfx(SfxType.buttonTap);
                    navigationShell.goBranch(index);
                  },
                  child: _buildNavItem(
                    dest,
                    isSelected,
                    isSelected ? iconSelectedSize : iconBaseSize,
                    navHeight,
                    context,
                   index ==
                        destinations.indexWhere(
                          (dest) => dest.label.toLowerCase().contains('grim'),
                        ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
Widget _buildNavItem(
    Destination dest,
    bool isSelected,
    double width,
    double navHeight,
    BuildContext context,
    bool isGrim,
  ) {
    final profile = context.readProfile;
    final hasUnread = isGrim && profile.unreadRecipeCount > 0;

    final scale = hasUnread ? 1.0 : 0.0;

    return SizedBox(
      height: navHeight,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            top: isSelected ? -15.0 : 20.0,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutBack,
                  width: width,
                  child: Image.asset(dest.imagePath, fit: BoxFit.contain),
                ),
                
                Positioned(
                  top: -5,
                  right: 0,
                  child: AnimatedScale(
                    scale: scale,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.palette.crimson,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        profile.unreadRecipeCount.toString(),
                        style: context.theme.textTheme.labelMedium?.copyWith(
                          color: context.palette.trueWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            bottom: isSelected ? 5.0 : -20.0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isSelected ? 1.0 : 0.0,
              child: Text(
                dest.label,
                style: context.theme.textTheme.titleSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
