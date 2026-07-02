import 'package:flutter/material.dart';
import 'package:grimoji/config/router/layout/shell_tab.dart';
import 'package:grimoji/utils/context_data.dart';
import 'content.dart';

class ScreenTicker extends StatefulWidget {
  const ScreenTicker({super.key});

  @override
  State<ScreenTicker> createState() => _ScreenTickerState();
}

class _ScreenTickerState extends State<ScreenTicker> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/emo_2.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watchProfile;
    final isGrimoireTab =
        ShellTabScope.maybeOf(context)?.isBranchActive(1) ?? true;

    final Set<String> unlockedSet = profile.unlockedRecipes.toSet();
    final Set<String> unreadSet = profile.unreadRecipeIds.toSet();
    final String? targetAutoOpenId = profile.unreadRecipeCount > 0
        ? profile.unreadRecipeIds.first
        : null;

    return TickerMode(
      enabled: isGrimoireTab,
      child: ScreenContent(
        unlockedRecipes: unlockedSet,
        unreadRecipes: unreadSet,
        targetAutoOpenId: targetAutoOpenId,
      ),
    );
  }
}
