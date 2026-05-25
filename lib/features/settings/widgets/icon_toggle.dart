import 'package:flutter/material.dart';
import 'package:grimoji/widgets/app_icon.dart';

class IconToggle extends StatelessWidget {
  final String fileName;
  final bool isActive;
  final VoidCallback onTap;
  final String? label;

  const IconToggle({
    super.key,
    required this.fileName,
    required this.isActive,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 125,
      child: Column(
        children: [
          AppIcon(
            fileName: fileName,
            size: 80,
            isActive: isActive,
            enableSound: false,
            enableAnimation: false,
            onTap: onTap,
          ),
          if (label != null) SizedBox(height: 12),
          if (label != null)
            Text(
              label!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.surfaceContainer,
                fontWeight: FontWeight.w600
              ),
            ),
        ],
      ),
    );
  }
}
