import 'package:flutter/material.dart';
import 'package:grimoji/features/cauldron/widgets/cauldron.dart';
import 'package:grimoji/features/cauldron/widgets/ranking.dart';

class CauldronScreen extends StatelessWidget {
  const CauldronScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/emo.png', fit: BoxFit.cover),
          ),
          const Positioned(
            bottom: -22,
            child: Cauldron(),
          ),
          const Positioned(top: 10, left: 0, right: 0, child: Ranking()),
        ],
      ),
    );
  }
}
