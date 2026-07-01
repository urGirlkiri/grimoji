import 'package:flutter/material.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/utils/context_data.dart';

class NavItem extends StatelessWidget {
  const NavItem({
    super.key,
    required this.dest,
    required this.isSelected,
    required this.width,
    required this.navHeight,
    required this.context,
    required this.isGrim,
  });

  final Destination dest;
  final bool isSelected;
  final double width;
  final double navHeight;
  final BuildContext context;
  final bool isGrim;

  @override
  Widget build(BuildContext context) {
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
