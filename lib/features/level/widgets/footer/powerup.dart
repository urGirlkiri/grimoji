import 'package:flutter/widgets.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class PowerupBtn extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;

  const PowerupBtn({super.key,  required this.assetPath, required this.onTap,});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: ShapeDecoration(
          color: context.palette.mist,
          shape: CircleBorder(side: BorderSide(width: 3, color: context.palette.dusk)),
          shadows: [
            BoxShadow(
              color: context.palette.voidBlack,
              blurRadius: 1,
              offset: Offset(1, 6),
            ),
          ],
        ),
        child: Center(
          child: EmojiWidget.svg(path: assetPath, size: 50,)
        ),
      ),
    );
  }
}