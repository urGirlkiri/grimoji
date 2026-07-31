import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/utils/context_data.dart';

class LevelFinder extends StatelessWidget {
  final bool isBelow;
  const LevelFinder({super.key, required this.isBelow});

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final bottom = isBelow ? 3.0 : null;
    final top = isBelow ? null : 3.0;
    return AnimatedPositioned(
      bottom: bottom,
      top: top,
      left: context.screenWidth / 2 - (45 * scale),
      duration: const Duration(seconds: 1),
      child: Container(
        padding: const EdgeInsets.only(top: 20, left: 8, right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: context.palette.voidBlack.withValues(alpha: 100),
          borderRadius: BorderRadius.circular(100 * scale),
          border: Border.all(color: context.palette.moonlight, width: 2),
        ),
        child: SizedBox(
          width: 50,
          height: 50,
          child: Container(
            color: context.palette.twilight,
            child: Padding(
              padding: EdgeInsets.all(8 * scale),
              child: Image.asset(
                'assets/avatars/fairy_blade.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ).animate(),
    );
  }
}
