import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';

class ShuffleIndicator extends StatelessWidget {
  const ShuffleIndicator({super.key, required this.edgeX});
  final double edgeX;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Positioned(
      left: edgeX - 25,
      top: 0,
      bottom: 0,
      width: 30,
      child: Container(
        decoration: BoxDecoration(
          color: palette.trueWhite,
          gradient: LinearGradient(
            colors: [palette.voidBlack, palette.trueWhite, palette.midnight],
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: palette.voidBlack.withValues(alpha: .5),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(-8, 0),
            ),
          ],
        ),
      ),
    );
  }
}
