import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:grimoji/app/palette.dart';

class CauldronGame extends FlameGame{
  final ColorScheme colorScheme;
  final double globalScale;
  static final palette = Palette();

  CauldronGame({required this.colorScheme, required this.globalScale});

  @override
  Color backgroundColor() {
    return palette.midnight;
  }

}