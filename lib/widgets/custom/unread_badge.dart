import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';

class UnreadBadge extends StatelessWidget {
  const UnreadBadge({super.key, this.width = 10.00, this.height = 10.00});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: palette.crimson,
        borderRadius: BorderRadius.circular(25),
      ),
    );
  }
}
