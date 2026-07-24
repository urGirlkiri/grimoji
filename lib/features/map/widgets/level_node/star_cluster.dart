import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/star_icon.dart';

class StarCluster extends StatelessWidget {
  final int count;
  final int crimsonStars;
  const StarCluster(this.count, {super.key, this.crimsonStars = 0});

  @override
  Widget build(BuildContext context) {
    if (count == 1) {
      return _Star(size: 24, crimson: crimsonStars > 0);
    }

    if (count == 2) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _Star(size: 24, crimson: crimsonStars > 0),
          _Star(size: 24, crimson: crimsonStars > 1),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Star(size: 24, crimson: crimsonStars > 0),
        Transform.translate(
          offset: const Offset(0, -6),
          child: _Star(size: 26, crimson: crimsonStars > 1),
        ),
        _Star(size: 24, crimson: crimsonStars > 2),
      ],
    );
  }
}

class _Star extends StatelessWidget {
  final double size;
  final bool crimson;

  const _Star({required this.size, required this.crimson});

  @override
  Widget build(BuildContext context) {
    return StarIcon(
      size: size,
      color: crimson ? context.palette.crimson : null,
    );
  }
}
