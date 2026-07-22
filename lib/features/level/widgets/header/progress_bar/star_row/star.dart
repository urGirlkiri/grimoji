import 'package:flutter/material.dart';
import 'package:grimoji/widgets/custom/star_icon.dart';

class Star extends StatelessWidget {
  const Star({super.key, required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.8,
      duration: const Duration(milliseconds: 500),
      curve: Curves.elasticOut,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 300),
        child: const StarIcon(size: 32),
      ),
    );
  }
}
