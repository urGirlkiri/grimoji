import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';

Future<T?> showAnimatedDialog<T>(BuildContext context, Widget dialog) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: context.palette.voidBlack.withValues(alpha: 0.7), 
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) => dialog,
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.6, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
          ),
          child: child,
        ),
      );
    },
  );
}
