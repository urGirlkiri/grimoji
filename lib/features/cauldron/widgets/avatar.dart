import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';

class Avatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color? backgroundColor;
  final BoxBorder? border;
  final double? scale;
  final VoidCallback? onTap;

  const Avatar({
    super.key,
    required this.name,
    this.radius = 32,
    this.backgroundColor,
    this.border,
    this.scale,
    this.onTap,
  });

  String get avatarPath => 'assets/avatars/$name.png';

  @override
Widget build(BuildContext context) {
  return AnimatedButton(
    onTap: onTap ?? (){},
    child: Container(
      width: 75 * context.globalScale,
      height: 80 * context.globalScale,
      margin: EdgeInsets.symmetric(horizontal: 10 * context.globalScale),
      padding: EdgeInsets.all(8 * context.globalScale), 
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24 * context.globalScale),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
            offset: Offset(0, 5 * context.globalScale),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            offset: Offset(0, 4 * context.globalScale),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * context.globalScale),
        child: Image.asset(
          avatarPath,
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}
}
