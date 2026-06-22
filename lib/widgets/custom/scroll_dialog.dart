import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';

enum ScrollType {
  fullyOpenHorizontal,
  fullyOpenVertical,
  horizontalLong,
  horizontalShort,
  verticalShort,
  verticalWideLong,
  verticalThinLong,
}

class ScrollDialog extends StatelessWidget {
  final Widget child;
  final Widget? rightButton;
  final Widget? leftButton;
  final EdgeInsets? padding;
  final ScrollType? scrollType;

  const ScrollDialog({
    super.key,
    required this.child,
    this.rightButton,
    this.leftButton,
    this.padding,
    this.scrollType = ScrollType.verticalWideLong,
  });

  String _getScrollImage(ScrollType type) {
    switch (type) {
      case ScrollType.verticalWideLong:
        return 'verticalWideLong';
      case ScrollType.fullyOpenHorizontal:
        return 'fullyOpenHorizontal';
      case ScrollType.horizontalShort:
        return 'horizontalShort';
      case ScrollType.horizontalLong:
        return 'horizontalLong';
      default:
        return 'verticalWideLong';
    }
  }

  Size _getDialogSize(ScrollType type, bool isLarge, double maxWidth, double maxHeight) {
    switch (type) {
      case ScrollType.horizontalShort:
        final w = isLarge ? 500.0 : maxWidth.clamp(280.0, 500.0);
        return Size(w, w * 0.365);
      case ScrollType.horizontalLong:
        final w = isLarge ? 600.0 : maxWidth.clamp(280.0, 600.0);
        return Size(w, w * .84);
      case ScrollType.fullyOpenHorizontal:
        final w = isLarge ? 550.0 : maxWidth.clamp(300.0, 550.0);
        return Size(w, (w * 1.1).clamp(180.0, maxHeight));
      case ScrollType.verticalWideLong:
      default:
        final w = isLarge ? 677.0 : maxWidth.clamp(280.0, 677.0);
        final h = isLarge ? 900.0 : maxHeight.clamp(400.0, 818.0);
        return Size(w, h);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLarge = context.isLargeScreen;
    final screenSize = MediaQuery.sizeOf(context);
    final screenWidth = context.screenWidth;
    final maxDialogWidth = screenWidth * 0.9;
    final maxDialogHeight = screenSize.height * 0.8;
    final size = _getDialogSize(scrollType!, isLarge, maxDialogWidth, maxDialogHeight);
    final dialogWidth = size.width;
    final dialogHeight = size.height;
    final String scrollImage =
        'assets/images/scrolls/${_getScrollImage(scrollType!)}.png';

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: dialogWidth,
        maxHeight: dialogHeight,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Image.asset(
            scrollImage,
            fit: BoxFit.fill,
            width: dialogWidth,
            height: dialogHeight,
          ),
          SizedBox.expand(child: child),
          if (rightButton != null)
            Positioned(
              top: isLarge ? -15 : -8,
              right: isLarge ? -1 : -8,
              child: SizedBox(
                width: isLarge ? 80 : 60,
                height: isLarge ? 80 : 60,
                child: rightButton!,
              ),
            ),
          if (leftButton != null)
            Positioned(
              top: isLarge ? -15 : -8,
              left: isLarge ? -1 : -8,
              child: SizedBox(
                width: isLarge ? 80 : 60,
                height: isLarge ? 80 : 60,
                child: leftButton!,
              ),
            ),
        ],
      ),
    );
  }
}
