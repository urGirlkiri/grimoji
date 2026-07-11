import 'package:flutter/material.dart';
import 'package:grimoji/features/level/widgets/overlays/powerup_selection/desktop.dart';
import 'package:grimoji/features/level/widgets/overlays/powerup_selection/mobile.dart';
import 'package:provider/provider.dart';
import 'package:grimoji/features/level/state.dart';

class PowerupSelectionOverlay extends StatelessWidget {
  const PowerupSelectionOverlay({super.key, required this.boardKey});

  final GlobalKey boardKey;

  @override
  Widget build(BuildContext context) {
    return Selector<LevelState, bool>(
      selector: (_, state) => state.isPowerupSelecting,
      builder: (context, isSelecting, child) {
        if (!isSelecting) return const SizedBox.shrink();

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final isMobile = size.height >= size.width;

            if (isMobile) {
              return Mobile(size: size, boardKey: boardKey);
            } else {
              return Desktop(size: size, boardKey: boardKey);
            }
          },
        );
      },
    );
  }
}
