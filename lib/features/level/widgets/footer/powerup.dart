import 'package:flutter/widgets.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/animated_button.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class PowerupBtn extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;
  final Color? borderColor;
  final Color? bgColor;
  final Color? shadowColor;

  const PowerupBtn({
    super.key,
    required this.assetPath,
    required this.onTap,
    this.borderColor,
    this.bgColor,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    return AnimatedButton(
      onTap: onTap,
      child: Container(
        width: 70 * scale,
        height: 70 * scale,
        decoration: ShapeDecoration(
          color: bgColor ?? context.palette.mist,
          shape: CircleBorder(
            side: BorderSide(
              width: 3 * scale,
              color: borderColor ?? context.palette.dusk,
            ),
          ),
          shadows: [
            BoxShadow(
              color: shadowColor ?? context.palette.voidBlack,
              blurRadius: 1,
              offset: const Offset(1, 6),
            ),
          ],
        ),
        child: Center(child: EmojiWidget.svg(path: assetPath, size: 45 * scale)),
      ),
    );
  }
}
