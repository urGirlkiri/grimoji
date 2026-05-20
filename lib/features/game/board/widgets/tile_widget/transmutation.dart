import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TileTransmutation extends StatelessWidget {
  const TileTransmutation({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: OverflowBox(
        maxWidth: size * 1.2,
        maxHeight: size * 1.2,
        child: Transform.translate(
          offset: const Offset(-25.0, 0.0),
          child: Lottie.asset(
            "assets/lottie/puff.json",
            width: size * 1.2,
            height: size * 1.2,
            fit: BoxFit.cover,
            animate: true,
            repeat: false,
            delegates: LottieDelegates(
              values: [
                ValueDelegate.colorFilter([
                  '**',
                ], value: ColorFilter.mode(color, BlendMode.srcATop)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
