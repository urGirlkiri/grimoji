import 'package:flutter/material.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:provider/provider.dart';
import 'package:grimoji/features/grimoire/widgets/ticker/index.dart';

class GrimoireScreen extends StatelessWidget {
  const GrimoireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.select<ProfileController, int>((p) => p.profileVersion);
    final bool isLoaded = context.select<ProfileController, bool>(
      (p) => p.isLoaded,
    );

    if (!isLoaded) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E0E1E),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return const ScreenTicker();
  }
}
