import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/board/widgets/announcer/text.dart';
import 'package:provider/provider.dart';

class AnnouncerWidget extends StatelessWidget {
  const AnnouncerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: _IsolatedAnnouncerLeaf(),
    );
  }
}

class _IsolatedAnnouncerLeaf extends StatelessWidget {
  const _IsolatedAnnouncerLeaf();

  @override
  Widget build(BuildContext context) {
    final phrase = context.select<LevelState, String?>(
      (s) => s.gameState.activeAnnouncement,
    );
    final token = context.select<LevelState, int>(
      (s) => s.gameState.announcementToken,
    );

    if (phrase == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      key: ValueKey(token),
      child: AnText(phrase: phrase)
          .animate()
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
    );
  }
}

