import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/header/progress_bar/index.dart';
import 'package:grimoji/features/level/widgets/header/progress_row/level_text.dart';
import 'package:provider/provider.dart';

class ProgressRow extends StatelessWidget {
  const ProgressRow({super.key});

  @override
  Widget build(BuildContext context) {
    final hasCollectedTarget = context.select<LevelState, bool>(
      (state) => state.collectedAmount > 0,
    );

    if (!hasCollectedTarget) return const SizedBox.shrink();

    return const Padding(
      padding: EdgeInsets.only(top: 24),
      child: Row(
        children: [
          LevelText(),
          SizedBox(width: 12),
          Expanded(child: ProgressBar()),
        ],
      ),
    );
  }
}
