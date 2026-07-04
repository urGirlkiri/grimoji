import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/effects/line_clear.dart';
import 'package:grimoji/features/match/board/widgets/overlays/line_clear/beam.dart';

class LineClearOverlay extends StatelessWidget {
  final ValueNotifier<List<LineClearEffect>> notifier;
  final double tileWidth;
  final double tileHeight;
  final int cols;
  final int rows;

  const LineClearOverlay({
    super.key,
    required this.notifier,
    required this.tileWidth,
    required this.tileHeight,
    required this.cols,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<LineClearEffect>>(
      valueListenable: notifier,
      builder: (context, effects, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: effects.map((effect) {
            return ClearBeam(
              key: ValueKey(effect.id),
              tileWidth: tileWidth,
              tileHeight: tileHeight,
              cols: cols,
              rows: rows,
              isHorizontal: effect.isHorizontal,
              triggerRow: effect.row,
              triggerCol: effect.col,
            );
          }).toList(),
        );
      },
    );
  }
}
