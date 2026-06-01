import 'package:flutter/material.dart';

class UnreadBadge extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final bool showShadow;

  const UnreadBadge({
    super.key,
    required this.color,
    required this.borderColor,
    this.showShadow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
    );
  }
}
