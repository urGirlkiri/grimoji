import 'package:flutter/material.dart';
import 'package:grimoji/utils/responsive.dart';

class ScrollDialog extends StatelessWidget {
  final Widget child;
  final Widget? rightButton;
  final Widget? leftButton;
  final EdgeInsets? padding;

  const ScrollDialog({
    super.key,
    required this.child,
    this.rightButton,
    this.leftButton,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isLarge = context.isLargeScreen;

    return SizedBox(
      width: 677,
      height: isLarge ? 1000 : 818,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/images/scroll.png',
            fit: BoxFit.fitWidth,
            width: 677,
            height: 1000,
          ),

          Padding(
            padding: padding ?? const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 40.0,
            ),
            child: child, 
          ),

          if (rightButton != null)
            Positioned(
              top: isLarge ? -15 : -1,
              right: isLarge ? -1 : -1,
              child: rightButton!,
            ),
          if (leftButton != null)
            Positioned(
              top: isLarge ? -15 : -1,
              left: isLarge ? -1 : -1,
              child: leftButton!,
            ),
        ],
      ),
    );
  }
}