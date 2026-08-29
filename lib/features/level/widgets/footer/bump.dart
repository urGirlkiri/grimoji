import 'package:flutter/material.dart';

class PowerupBump extends StatefulWidget {
  final ValueNotifier<int> token;
  final Widget child;

  const PowerupBump({super.key, required this.token, required this.child});

  @override
  State<PowerupBump> createState() => PowerupBumpState();
}

class PowerupBumpState extends State<PowerupBump>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.35,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.35,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_controller);
    widget.token.addListener(_onBump);
  }

  void _onBump() {
    if (!mounted) return;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    widget.token.removeListener(_onBump);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: widget.child,
    );
  }
}
