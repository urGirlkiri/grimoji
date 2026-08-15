import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grimoji/config/router/routes.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:lottie/lottie.dart';

class Cauldron extends StatelessWidget {
  const Cauldron({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onTap: () => context.pushNamed(Routes.cauldronPlay),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double size = (constraints.maxWidth * 0.95).clamp(250.0, 600.0);
          return SizedBox(
            width: size,
            height: size,
            child: RepaintBoundary(
              child: Lottie.asset(
                'assets/lottie/cauldron.json',
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          );
        },
      ),
    );
  }
}
