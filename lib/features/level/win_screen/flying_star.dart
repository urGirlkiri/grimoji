import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/widgets/custom/star_icon.dart';

class FlyingStar extends StatelessWidget {
  final int index;
  final int total;

  const FlyingStar({super.key, required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    final double xSpread = total > 1 ? (index - (total - 1) / 2) : 0;

    return const StarIcon(size: 60)
        .animate(delay: Duration(milliseconds: index * 200))
        .moveX(begin: 0, end: xSpread * 50)
        .moveY(begin: 0, end: -50)
        .rotate(begin: 2.0, end: 0.0)
        .scaleXY(begin: 0.0, end: 1.5);
  }
}
