import 'package:flutter/material.dart';

class DimOverlayClipper extends CustomClipper<Path> {
  final Rect boardRect;

  DimOverlayClipper({required this.boardRect});

  @override
  Path getClip(Size size) {
    final screenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final boardPath = Path()..addRect(boardRect);
    
    return Path.combine(
      PathOperation.difference,
      screenPath,
      boardPath,
    );
  }

  @override
  bool shouldReclip(DimOverlayClipper oldClipper) {
    return oldClipper.boardRect != boardRect;
  }
}