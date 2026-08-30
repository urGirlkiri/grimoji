import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/effects/ufo/effect.dart';

class UFOAnimation extends StatefulWidget {
  final UFOEffect effect;
  final double tileWidth;
  final double tileHeight;

  const UFOAnimation({
    super.key,
    required this.effect,
    required this.tileWidth,
    required this.tileHeight,
  });

  @override
  State<UFOAnimation> createState() => _UFOAnimationState();
}

class _UFOAnimationState extends State<UFOAnimation> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
