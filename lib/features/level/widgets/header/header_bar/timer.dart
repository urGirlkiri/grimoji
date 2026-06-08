import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class TimerBox extends StatelessWidget {
  const TimerBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: ShapeDecoration(
        color: context.palette.dusk,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: ShapeDecoration(
              color: context.palette.slate,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Time',
              style: TextStyle(color: context.palette.trueWhite, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          const _TimerText()
        ],
      ),
    );
  }
}

class _TimerText extends StatelessWidget {
  const _TimerText();

  @override
  Widget build(BuildContext context) {
    final seconds = context.select((LevelState state) => state.secondsRemaining);
    return Text(
      seconds.toString(),
      style: TextStyle(
        color: context.palette.trueWhite,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}