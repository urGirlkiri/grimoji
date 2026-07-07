import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:provider/provider.dart';

class EmojiShuffler extends StatelessWidget {
  final double size;

  const EmojiShuffler({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final availableEmojis = context.select<LevelState, List<String>>(
      (s) => s.level.availableEmojis.map((e) => e.visual).toList(),
    );

    return const SizedBox.shrink(key: ValueKey('shuffler'))
        .animate(onPlay: (c) => c.repeat())
        .custom(
          duration: clownEmojiCycleDuration,
          builder: (context, value, child) {
            final cycleIndex =
                (value * availableEmojis.length).floor() %
                availableEmojis.length;
            return Text(
              availableEmojis[cycleIndex],
              style: TextStyle(fontSize: size),
            );
          },
        )
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          curve: Curves.easeOut,
        );
  }
}
