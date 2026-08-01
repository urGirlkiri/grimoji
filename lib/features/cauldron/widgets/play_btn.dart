import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/widgets/custom/pill_button.dart';

class PlayBtn extends StatelessWidget {
  const PlayBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return PillButton(
      text: "Start Your Own Fire",
      color: palette.dusk,
      borderColor: palette.slate,
      textColor: palette.mist,
      onTap: () => context.pushNamed(Routes.cauldronPlay),
    );
  }
}
