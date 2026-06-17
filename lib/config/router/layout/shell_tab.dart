import 'package:flutter/widgets.dart';

/// Exposes which bottom-nav  is currently visible inside
/// [StatefulShellRoute.indexedStack], so off-tab screens can pause work.
class ShellTabScope extends InheritedWidget {
  const ShellTabScope({
    required this.activeIndex,
    required super.child,
    super.key,
  });

  final int activeIndex;

  // ignore: avoid_returning_widgets
  static ShellTabScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ShellTabScope>();
  }

  bool isBranchActive(int branchIndex) => activeIndex == branchIndex;

  @override
  bool updateShouldNotify(ShellTabScope oldWidget) {
    return activeIndex != oldWidget.activeIndex;
  }
}
