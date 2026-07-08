import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/effects/time_bonus/animation.dart';
import 'package:grimoji/features/match/board/effects/time_bonus/effect.dart';

class TimeBonusOverlay extends StatelessWidget {
  final ValueNotifier<List<TimeBonusEffect>> effectsNotifier;

  const TimeBonusOverlay({super.key, required this.effectsNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TimeBonusEffect>>(
      valueListenable: effectsNotifier,
      builder: (context, effects, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: effects.map((effect) {
            return TimeBonusAnimation(
              key: ValueKey(effect.id),
              effect: effect,
            );
          }).toList(),
        );
      },
    );
  }
}