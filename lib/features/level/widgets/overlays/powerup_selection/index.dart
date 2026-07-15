import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/overlays/powerup_selection/content.dart';
import 'package:grimoji/features/level/widgets/overlays/punch_animation/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class PowerupSelectionOverlay extends StatelessWidget {
  const PowerupSelectionOverlay({super.key, required this.boardKey});

  static final _log = Logger('PowerupSelectionOverlay');

  final GlobalKey boardKey;

  Rect _getBoardRect() {
    final renderBox = boardKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      _log.warning('boardKey RenderBox not found.');
      return Rect.zero;
    }
    return renderBox.localToGlobal(Offset.zero) & renderBox.size;
  }

  @override
  Widget build(BuildContext context) {
    return Selector<LevelState, bool>(
      selector: (_, state) =>
          state.isPowerupSelecting || state.isPowerupAnimating,
      builder: (context, showOverlay, child) {
        if (!showOverlay) return const SizedBox.shrink();

        final boardRect = _getBoardRect();

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final isMobile = size.height >= size.width;
            const double top = 0;
            final double? bottom = isMobile ? null : 0;
            final double? left = isMobile ? 0 : null;
            const double right = 0;
            final double? width = isMobile ? null : size.width * 0.3;

            return Selector<LevelState, bool>(
              selector: (_, state) => state.isPowerupAnimating,
              builder: (context, isAnimating, child) {
                return Stack(
                  children: [
                    Positioned.fromRect(
                      rect: Rect.fromLTWH(0, 0, size.width, boardRect.top),
                      child: GestureDetector(
                        onTap: isAnimating
                            ? null
                            : () {
                                _log.fine('Tap above board — cancelling');
                                context
                                    .read<LevelState>()
                                    .cancelPowerupSelection();
                              },
                        child: Container(
                          color: context.palette.voidBlack.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fromRect(
                      rect: Rect.fromLTWH(
                        0,
                        boardRect.bottom,
                        size.width,
                        size.height - boardRect.bottom,
                      ),
                      child: GestureDetector(
                        onTap: isAnimating
                            ? null
                            : () {
                                _log.fine('Tap below board — cancelling');
                                context
                                    .read<LevelState>()
                                    .cancelPowerupSelection();
                              },
                        child: Container(
                          color: context.palette.voidBlack.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fromRect(
                      rect: Rect.fromLTWH(
                        0,
                        boardRect.top,
                        boardRect.left,
                        boardRect.height,
                      ),
                      child: GestureDetector(
                        onTap: isAnimating
                            ? null
                            : () {
                                _log.fine('Tap left of board — cancelling');
                                context
                                    .read<LevelState>()
                                    .cancelPowerupSelection();
                              },
                        child: Container(
                          color: context.palette.voidBlack.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fromRect(
                      rect: Rect.fromLTWH(
                        boardRect.right,
                        boardRect.top,
                        size.width - boardRect.right,
                        boardRect.height,
                      ),
                      child: GestureDetector(
                        onTap: isAnimating
                            ? null
                            : () {
                                _log.fine('Tap right of board — cancelling');
                                context
                                    .read<LevelState>()
                                    .cancelPowerupSelection();
                              },
                        child: Container(
                          color: context.palette.voidBlack.withValues(
                            alpha: 0.9,
                          ),
                        ),
                      ),
                    ),
                    if (!isAnimating)
                      Positioned(
                        top: top,
                        bottom: bottom,
                        left: left,
                        right: right,
                        width: width,
                        child: const Content(),
                      ),
                    if (isAnimating) PunchingOverlay(boardRect: boardRect),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
