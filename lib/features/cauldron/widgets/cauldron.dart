import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:lottie/lottie.dart';

class Cauldron extends StatelessWidget {
  const Cauldron({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final size = 230 * scale;

    return AnimatedButton(
      onTap: () => context.pushNamed(Routes.cauldronPlay),
      child: RepaintBoundary(
        child: OverflowBox(
          maxWidth: size * 30,
          maxHeight: double.infinity,
          child: Lottie.asset(
            'assets/lottie/cauldron.json',
            fit: BoxFit.cover,
            repeat: true,
          ),
        ),
      ),
    );
  }
}
