import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grimoji/utils/context_data.dart';

class StarIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const StarIcon({
    super.key,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/emojis/svg/star.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: ColorFilter.mode(
        color ?? context.palette.mist,
        BlendMode.srcIn,
      ),
    );
  }
}
