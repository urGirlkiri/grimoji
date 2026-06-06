import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:grimoji/features/cauldron/game/index.dart';
import 'package:grimoji/features/level/hint_screen/loading.dart';
import 'package:grimoji/utils/context_data.dart';

class CauldronPlayScreen extends StatelessWidget {
  const CauldronPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: CauldronGame(
          colorScheme: context.theme.colorScheme,
          globalScale: context.globalScale,
        ),
        loadingBuilder: (context) => const Loading(),
      ),
    );
  }
}
