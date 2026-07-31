import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';

class ProfileAvatar extends StatelessWidget {
  final String avatar;
  final double width;
  final double height;

  const ProfileAvatar({
    super.key,
    required this.avatar,
    this.width = 75,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scale = context.globalScale;

    return Transform.translate(
      offset: Offset(0, -10 * scale),
      child: Container(
        width: width * scale,
        height: height * scale,
        margin: EdgeInsets.symmetric(horizontal: 6 * scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: palette.twilight, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: palette.slate.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
              offset: Offset(0, 5 * scale),
            ),
            BoxShadow(
              color: palette.midnight,
              offset: Offset(0, 4 * scale),
              blurRadius: 0,
            ),
          ],
          image: DecorationImage(
            image: AssetImage('assets/avatars/$avatar.png'),
            fit: BoxFit.cover,
          ),
      ),
    ));
  }
}
