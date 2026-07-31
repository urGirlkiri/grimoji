import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';

class GamePlaque extends StatelessWidget {
  final Widget? pchild;
  final Widget? child;
  final Color backgroundColor;
  final double? height;

  const GamePlaque({
    super.key,
    this.pchild,
    this.child,
    this.backgroundColor = Colors.transparent,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final topPadding = MediaQuery.paddingOf(context).top;
    final plaqueHeight = height ?? (90.0 * scale) + topPadding;

    return SizedBox(
      height: plaqueHeight + 15 * scale,
      child: Container(
        color: backgroundColor,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: plaqueHeight,
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
                  // BoxShadow(
                  //   color: context.palette.voidBlack.withValues(alpha: 0.3),
                  //   offset: Offset(0, 10 * scale),
                  //   blurRadius: 10,
                  //   spreadRadius: 1,
                  // ),
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
            if (pchild != null)
              Positioned(
                top: (20 * scale) + topPadding,
                left: 12 * scale,
                right: 12 * scale,
                child: pchild!,
              ),
            ?child,
          ],
        ),
      ),
    );
  }
}
