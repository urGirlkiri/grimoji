import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class Sky extends StatelessWidget {
  const Sky({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          EmojiWidget.lottie(path: Emojis.cloud.lottie, size: 80,),
          EmojiWidget.lottie(path: Emojis.cloudWithLightning.lottie, size: 80,),
          EmojiWidget.lottie(path: Emojis.rainCloud.lottie, size: 80,),
        ],
      ),
    );
  }
}
