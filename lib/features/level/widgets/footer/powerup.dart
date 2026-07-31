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
  final int count;

  const PowerupBtn({
    super.key,
    required this.assetPath,
    required this.onTap,
    this.borderColor,
    this.bgColor,
    this.shadowColor,
    this.count = 0,
  });

  @override
  Widget build(BuildContext context) {
    final scale = context.globalScale;
    final palette = context.palette;
    return AnimatedButton(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 70 * scale,
            height: 70 * scale,
            decoration: ShapeDecoration(
              color: bgColor ?? palette.mist,
              shape: CircleBorder(
                side: BorderSide(
                  width: 3 * scale,
                  color: borderColor ?? palette.dusk,
                ),
              ),
              shadows: [
                BoxShadow(
                  color: shadowColor ?? palette.voidBlack,
                  blurRadius: 1,
                  offset: const Offset(1, 6),
                ),
              ],
            ),
            child: Center(
              child: EmojiWidget(assetPath: assetPath, size: 45 * scale),
            ),
          ),
          if (count > 0)
            Positioned(
              top: -10,
              right: -6,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: palette.twilight,
                  shape: BoxShape.circle,
                  border: Border.all(color: palette.dusk, width: 1.5),
                ),
                child: Text(
                  count.toString(),
                  style: context.theme.textTheme.bodyLarge,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
