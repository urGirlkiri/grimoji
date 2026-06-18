import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class ShuffleAnimator extends StatelessWidget {
  const ShuffleAnimator({
    super.key,
    required this.boardWidth,
    required this.child,
  });

  final double boardWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final shuffleProgress = context.select<LevelState, double>(
      (s) => s.gameState.shuffleProgress,
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: shuffleProgress),
      duration: TileGrid.shuffleDuration,
      curve: Curves.easeInOutCubic,

      child: child,
      builder: (context, widthFactor, cachedGridStack) {
        final double edgeX = boardWidth * widthFactor;
        final palette = context.palette;

        return Stack(
          children: [
            ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: widthFactor,
                child: SizedBox(width: boardWidth, child: cachedGridStack),
              ),
            ),
            if (widthFactor > 0.0 && widthFactor < 1.0)
              Positioned(
                left: edgeX - 25,
                top: 0,
                bottom: 0,
                width: 30,
                child: Container(
                  decoration: BoxDecoration(
                    color: palette.trueWhite,
                    gradient: LinearGradient(
                      colors: [
                        palette.voidBlack,
                        palette.trueWhite,
                        palette.midnight,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: palette.voidBlack.withValues(alpha: .5),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(-8, 0),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
