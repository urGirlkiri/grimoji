import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';

class Avatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color? backgroundColor;
  final BoxBorder? border;
  final VoidCallback? onTap;

  const Avatar({
    super.key,
    required this.name,
    this.radius = 32,
    this.backgroundColor,
    this.border,
    this.onTap,
  });

  String get avatarPath => 'assets/avatars/$name.png';

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    

    return AnimatedButton(
      onTap: onTap ?? () {},
      child: Container(
        width: 75 * scale,
        height: 80 * scale,
        margin: EdgeInsets.symmetric(horizontal: 10 * scale),
        padding: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24 * scale),
          border: border,
          boxShadow: backgroundColor != null ? [
            BoxShadow(
              color: palette.voidBlack.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
              offset: Offset(0, 5 * scale),
            ),
            BoxShadow(
              color: palette.voidBlack.withValues(alpha: 0.5),
              offset: Offset(0, 4 * scale),
              blurRadius: 0,
            ),
          ] : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16 * scale),
          child: Image.asset(avatarPath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
