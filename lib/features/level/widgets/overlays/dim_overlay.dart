import 'package:flutter/material.dart';

class DimOverlayPainter extends CustomPainter {
  final Rect boardRect;
  final Color dimColor;

  DimOverlayPainter({required this.boardRect, required this.dimColor});

  @override
  void paint(Canvas canvas, Size size) {
    final screenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final boardPath = Path()..addRect(boardRect);
    final overlayPath = Path.combine(
      PathOperation.difference,
      screenPath,
      boardPath,
    );

    final paint = Paint()..color = dimColor;
    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(DimOverlayPainter oldDelegate) {
    return oldDelegate.boardRect != boardRect ||
        oldDelegate.dimColor != dimColor;
  }
}
