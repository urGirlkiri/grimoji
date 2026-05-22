import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class TileExplosion extends StatelessWidget {
  const TileExplosion({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: OverflowBox(
        maxWidth: size * 30,
        maxHeight: size * 30,
        child: Transform.translate(
          offset: const Offset(1.0, 200.0),
          child: Transform.rotate(
            angle: 180,
            child: Lottie.asset(
              "assets/lottie/explosion.json",
              width: size * 10,
              height: size * 10,
              fit: BoxFit.cover,
              animate: true,
              repeat: false,
            ),
          ),
        ),
      ),
    );
  }
}
