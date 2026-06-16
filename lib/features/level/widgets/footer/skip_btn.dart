import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';

class SkipBtn extends StatelessWidget {
  final VoidCallback onSkip;

  const SkipBtn({super.key, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Center(
        child: PillButton(
          text: 'SKIP',
          color: palette.dusk,
          borderColor: palette.slate,
          onTap: onSkip,
        ),
      ),
    );
  }
}
