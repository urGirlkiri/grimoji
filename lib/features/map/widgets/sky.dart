import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class Sky extends StatelessWidget {
  const Sky({super.key});

  static const size = 65.0;
  static const opacity = 0.0345;
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          EmojiWidget.lottie(path: Emojis.rainCloud.lottie, size: size),
          EmojiWidget.lottie(
            path: Emojis.cloudWithLightning.lottie,
            size: size,
          ),
          EmojiWidget.lottie(path: Emojis.rainCloud.lottie, size: size),
        ],
      ),
    );
  }
}
