import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';

class PlayBtn extends StatelessWidget {
  const PlayBtn({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return PillButton(
      text: "Start Your Own fire",
      color: palette.dusk,
      textColor: palette.mist,
      onTap: () => {},
    );
  }
}
