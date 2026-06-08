import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:grimoji/features/cauldron/game/index.dart';
import 'package:grimoji/features/level/hint_screen/loading.dart';
import 'package:grimoji/utils/context_data.dart';

class CauldronPlayScreen extends StatefulWidget {
  const CauldronPlayScreen({super.key});

  @override
  State<CauldronPlayScreen> createState() => _CauldronPlayScreenState();
}

class _CauldronPlayScreenState extends State<CauldronPlayScreen> {
  late final CauldronGame _game;
  bool _isGameInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isGameInitialized) {
      _game = CauldronGame(
        colorScheme: context.theme.colorScheme,
        globalScale: context.globalScale,
        context: context,
      );
      _isGameInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: _game,
        loadingBuilder: (context) => const Center(child: Loading()),
      ),
    );
  }
}
