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
  final double? maxHeight;

  const ScrollDialog({
    super.key,
    required this.child,
    this.rightButton,
    this.leftButton,
    this.padding,
    this.scrollType = ScrollType.verticalWideLong,
    this.maxHeight,
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

  Size _dialogSize(
    ScrollType type,
    bool isLarge,
    double maxWidth,
    double maxHeight,
  ) {
    switch (type) {
      case ScrollType.horizontalShort:
        final w = isLarge ? 500.0 : maxWidth.clamp(280.0, 500.0);
        return Size(w, w * 0.75);
      case ScrollType.horizontalLong:
        final w = isLarge ? 600.0 : maxWidth.clamp(280.0, 600.0);
        return Size(w, w * .84);
      case ScrollType.fullyOpenHorizontal:
        final w = isLarge ? 550.0 : maxWidth.clamp(300.0, 550.0);
        return Size(w, (w * (isLarge ? 1.32 : 1.5)).clamp(180.0, maxHeight));
      case ScrollType.verticalWideLong:
      default:
        final w = isLarge ? 677.0 : maxWidth.clamp(280.0, 677.0);
        final h = isLarge ? 900.0 : maxHeight.clamp(400.0, 818.0);
        return Size(w, h);
    }
  }

  EdgeInsetsGeometry _dialogPadding(ScrollType type) {
    double top = 0;
    double right = 0;
    double bottom = 0;
    double left = 0;

    switch (type) {
      case ScrollType.horizontalShort:
        top = 56;
        bottom = 50;
        right = 45;
        left = 45;
      case ScrollType.horizontalLong:
        top = 25;
        bottom = 45;
        right = 30;
        left = 30;
      case ScrollType.fullyOpenHorizontal:
        top = 56;
        bottom = 45;
        right = 23;
        left = 23;
      case ScrollType.verticalWideLong:
        top = 12;
        bottom = 24;
        right = 20;
        left = 20;
      default:
    }

    return EdgeInsets.only(top: top, bottom: bottom, left: left, right: right);
  }

  @override
  Widget build(BuildContext context) {
    final isLarge = context.isLargeScreen;
    final screenSize = MediaQuery.sizeOf(context);
    final screenWidth = context.screenWidth;

    final maxDialogWidth = screenWidth * 0.9;
    final maxDialogHeight = maxHeight ?? screenSize.height * 0.8;

    final size = _dialogSize(
      scrollType!,
      isLarge,
      maxDialogWidth,
      maxDialogHeight,
    );

    final dialogPadding = _dialogPadding(scrollType!);

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
          Positioned.fill(
            child: Padding(
              padding: dialogPadding,
              child: ClipRect(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ScrollConfiguration(
                      behavior: ScrollConfiguration.of(
                        context,
                      ).copyWith(scrollbars: false, overscroll: false),
                      child: SingleChildScrollView(
                        padding: padding,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                                constraints.maxHeight -
                                (padding?.vertical ?? 0),
                          ),
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          if (rightButton != null)
            Positioned(
              top: isLarge ? 1 : -8,
              right: isLarge ? -1 : -8,
              child: SizedBox(
                width: isLarge ? 80 : 60,
                height: isLarge ? 80 : 60,
                child: rightButton!,
              ),
            ),
          if (leftButton != null)
            Positioned(
              top: isLarge ? 1 : -8,
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
