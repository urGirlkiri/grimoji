import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';

class SkipBtn extends StatelessWidget {
  final VoidCallback onSkip;

  const SkipBtn({super.key, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    

    return Center(
      child: PillButton(
        text: 'SKIP',
        color: palette.dusk,
        borderColor: palette.slate,
        onTap: onSkip,
      ),
    );
  }
}
