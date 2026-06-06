import 'package:flutter/material.dart';
import 'package:grimoji/features/cauldron/widgets/cauldron.dart';
import 'package:grimoji/features/cauldron/widgets/play_btn.dart';
import 'package:grimoji/features/cauldron/widgets/ranking.dart';
import 'package:grimoji/widgets/responsive_screen.dart';

class CauldronScreen extends StatelessWidget {
  const CauldronScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ResponsiveScreen(
        topMessageArea: Ranking(),
        squarishMainArea: Cauldron(),
        rectangularMenuArea: PlayBtn(),
      ),
    );
  }
}
