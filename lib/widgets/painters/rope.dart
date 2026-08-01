import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';

class RopePainter extends CustomPainter {
  static const palette = Palette();

  const RopePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = palette.dusk
      ..strokeWidth = size.width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width / 2, 0);

    for (int i = 0; i < 8; i++) {
      final segH = size.height / 8;
      final x = size.width / 2 + (i.isEven ? 1.5 : -1.5);
      path.lineTo(x, segH * (i + 1));
    }

    canvas.drawPath(path, paint);

    final knot = Paint()
      ..color = palette.twilight
      ..style = PaintingStyle.fill;

    for (int i = 1; i < 8; i++) {
      final segH = size.height / 8;
      canvas.drawCircle(Offset(size.width / 2, segH * i), 1.8, knot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
