import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/utils/context_data.dart';

class AnimatedCount extends StatefulWidget {
  final int count;

  const AnimatedCount({super.key, required this.count});

  @override
  State<AnimatedCount> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<AnimatedCount> {
  int _oldCount = 0;

  @override
  void initState() {
    super.initState();
    _oldCount = widget.count;
  }

  @override
  void didUpdateWidget(covariant AnimatedCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != oldWidget.count) {
      _oldCount = oldWidget.count;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: _oldCount, end: widget.count),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Text(
          value.toString(),
          style: context.theme.textTheme.labelMedium?.copyWith(
            color: palette.trueWhite,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}
