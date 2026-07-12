import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/overlays/dim_overlay.dart';
import 'package:grimoji/features/level/widgets/overlays/powerup_selection/content.dart';
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
      selector: (_, state) => state.isPowerupSelecting,
      builder: (context, isSelecting, child) {
        if (!isSelecting) return const SizedBox.shrink();

        final boardRect = _getBoardRect();
        _log.fine('Overlay shown — boardRect: $boardRect');

        return LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.biggest;
            final isMobile = size.height >= size.width;
            const double top = 0;
            final double? bottom = isMobile ? null : 0;
            final double? left = isMobile ? 0 : null;
            const double right = 0;
            final double? width = isMobile ? null : size.width * 0.3;

            return Stack(
              children: [
                GestureDetector(
                  onTapDown: (details) {
                    final tap = details.globalPosition;
                    if (!boardRect.contains(tap)) {
                      _log.fine('Tap outside board');
                      _log.fine('Cancelling powerup');
                      context.read<LevelState>().cancelPowerupSelection();
                    } else {
                      _log.fine('Tap inside board');
                    }
                  },
                  child: CustomPaint(
                    size: size,
                    painter: DimOverlayPainter(
                      boardRect: boardRect,
                      dimColor: context.palette.voidBlack.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: top,
                  bottom: bottom,
                  left: left,
                  right: right,
                  width: width,
                  child: const Content(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
