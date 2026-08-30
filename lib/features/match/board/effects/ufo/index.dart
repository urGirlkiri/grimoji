import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/effects/ufo/effect.dart';

class UFOOverlay extends StatelessWidget {
  final ValueNotifier<List<UFOEffect>> notifier;
  const UFOOverlay({
    super.key,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder<List<UFOEffect>>(
      valueListenable: notifier,
      builder: (context, effects, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: effects.map((effect) {
            return Positioned(
              key: ValueKey(effect.id),
              child: const Placeholder()
            );
          }).toList(),
        );
      },
    );
  }
}
