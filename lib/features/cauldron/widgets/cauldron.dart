import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:lottie/lottie.dart';

class Cauldron extends StatelessWidget {
  const Cauldron({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final size = 200 * scale;

    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: size * 0.4,
            width: size,
            child: Stack(
              alignment: AlignmentGeometry.center,
              children: List.generate(
                4,
                (i) => Positioned(
                  left: i *35,
                  child: EmojiWidget.lottie(
                    path: Emojis.fire.lottie,
                    size: size * 0.5,
                  ),
                ),
              ),
            ),
          ),
        ),
          RepaintBoundary(
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
      ],
    );
  }
}
