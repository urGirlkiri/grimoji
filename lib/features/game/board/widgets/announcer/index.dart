import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/features/game/board/widgets/announcer/text.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:provider/provider.dart';

class AnnouncerWidget extends StatelessWidget {
  const AnnouncerWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<LevelState>().gameState;

    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: AnText(key: ValueKey(gameState.announcementToken))
            .animate(key: ValueKey(gameState.announcementToken))
            .fadeIn(duration: 100.ms)
            .moveY(begin: 30, end: 0, duration: 200.ms, curve: Curves.easeOut)
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.0, 1.0),
              duration: 250.ms,
              curve: Curves.elasticOut,
            )
            .moveY(
              begin: 0,
              end: -40,
              delay: 1200.ms, 
              duration: 250.ms,
              curve: Curves.easeIn,
            )
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(0.5, 0.5),
              delay: 1200.ms,
              duration: 250.ms,
            )
            .fadeOut(delay: 1250.ms, duration: 200.ms),
      ),
    );
  }
}
