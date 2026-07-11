import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/overlays/dim_overlay.dart';
import 'package:grimoji/features/level/widgets/overlays/powerup_selection/content.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class Mobile extends StatelessWidget {
  const Mobile({super.key, required this.size, required this.boardKey});

  final Size size;
  final GlobalKey boardKey;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final renderBox = boardKey.currentContext?.findRenderObject() as RenderBox?;
    final boardRect = renderBox != null
        ? renderBox.localToGlobal(Offset.zero) & renderBox.size
        : Rect.zero;

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            context.read<LevelState>().cancelPowerupSelection();
          },
          child: CustomPaint(
            size: size,
            painter: DimOverlayPainter(
              boardRect: boardRect,
              dimColor: palette.voidBlack.withValues(alpha: 0.5),
            ),
          ),
        ),
        const Positioned(top: 0, left: 0, right: 0, child: Content()),
      ],
    );
  }
}
