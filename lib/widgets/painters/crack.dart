import 'dart:math';

import 'package:flutter/material.dart';
import 'package:grimoji/features/match/constants.dart';

class Crack {
  final List<Offset> points;

  Crack(this.points);
}

class FissureCracks extends StatefulWidget {
  final double size;
  final Color color;

  const FissureCracks({super.key, required this.size, required this.color});

  @override
  State<FissureCracks> createState() => FissureCracksState();
}

class FissureCracksState extends State<FissureCracks>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Crack> _cracks;

  @override
  void initState() {
    super.initState();
    final random = Random();
    final center = Offset(widget.size / 2, widget.size / 2);
    final cracks = <Crack>[];

    for (int i = 0; i < 10; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final length = widget.size * (0.45 + random.nextDouble() * 0.15);
      final end = center + Offset(cos(angle) * length, sin(angle) * length);
      final midBase = center + (end - center) * 0.5;
      final mid =
          midBase +
          Offset(
            (random.nextDouble() - 0.5) * widget.size * 0.25,
            (random.nextDouble() - 0.5) * widget.size * 0.25,
          );
      cracks.add(Crack([center, mid, end]));
    }

    _cracks = cracks;

    _controller = AnimationController(
      vsync: this,
      duration: lineClearBeamDuration,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: FissureCracksPainter(
        animation: _controller,
        cracks: _cracks,
        color: widget.color,
      ),
    );
  }
}

class FissureCracksPainter extends CustomPainter {
  final Animation<double> animation;
  final List<Crack> cracks;
  final Color color;

  FissureCracksPainter({
    required this.animation,
    required this.cracks,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final alpha = ((1.0 - animation.value) * 255).toInt();
    final paint = Paint()
      ..color = color.withAlpha(alpha)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final crack in cracks) {
      final path = Path()..moveTo(crack.points.first.dx, crack.points.first.dy);
      for (final point in crack.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FissureCracksPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.cracks != cracks;
  }
}
