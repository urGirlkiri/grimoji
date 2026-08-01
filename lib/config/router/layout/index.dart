import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/router/layout/nav_item.dart';
import 'package:grimoji/config/router/layout/shell_tab.dart';
import 'package:grimoji/features/audio/sounds/sfx.dart';
import 'package:grimoji/features/profile/widgets/game_bar/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/config/global_keys.dart';
import 'package:grimoji/config/router/routes.dart';

class LayoutScaffold extends StatelessWidget {
  const LayoutScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    
    final isLarge = context.isLargeScreen;

    final currentPath = GoRouterState.of(context).uri.path;
    final isMap = currentPath.startsWith(Routes.mapRoute);

    final double navHeight = isLarge ? 120.0 : 85.0;

    final double iconBaseSize = isLarge ? 100.0 : 60.0;
    final double iconSelectedSize = isLarge ? 120.0 : 80.0;

    return ShellTabScope(
      activeIndex: navigationShell.currentIndex,
      child: Scaffold(
        backgroundColor: isMap ? mapSkyColor : palette.midnight,
        body: Column(
          children: [
            GameBar(backgroundColor: isMap ? mapSkyColor : palette.midnight),
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
                palette.twilight.withValues(alpha: 0.8),
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
                    key:
                        index ==
                            destinations.indexWhere(
                              (dest) =>
                                  dest.label.toLowerCase().contains('grim'),
                            )
                        ? AppKeys.grimoireNavKey
                        : null,
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      context.readAudio.playSfx(Sfx.buttonTap);
                      navigationShell.goBranch(index);
                    },
                    child: NavItem(
                      dest: dest,
                      isSelected: isSelected,
                      width: isSelected ? iconSelectedSize : iconBaseSize,
                      navHeight: navHeight,
                      isGrim:
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
      ),
    );
  }
}
