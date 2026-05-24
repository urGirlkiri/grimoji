import 'package:flutter/material.dart';

class BreathingWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const BreathingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.minScale = 1.0,
    this.maxScale = 1.04,
  });

  @override
  State<BreathingWidget> createState() => _BreathingWidgetState();
}

class _BreathingWidgetState extends State<BreathingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: widget.minScale, end: widget.maxScale).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
      ),
      child: widget.child,
    );
  }
}