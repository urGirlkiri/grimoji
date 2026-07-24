import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/star_icon.dart';

class FlyingStar extends StatelessWidget {
  final int index;
  final int total;
  final bool crimson;

  const FlyingStar({
    super.key,
    required this.index,
    required this.total,
    this.crimson = false,
  });

  @override
  Widget build(BuildContext context) {
    final double xSpread = total > 1 ? (index - (total - 1) / 2) : 0;
    final color = crimson ? context.palette.crimson :  null;

    return StarIcon(size: 60, color: color)
        .animate(delay: Duration(milliseconds: index * 300))
        .moveX(begin: 0, end: xSpread * 60)
        .moveY(begin: 0, end: -50)
        .rotate(begin: 2.0, end: 0.0)
        .scaleXY(begin: 0.0, end: 1.5);
  }
}
