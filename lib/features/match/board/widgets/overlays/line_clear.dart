import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/match/board/models/line_clear.dart';

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
            return _LineClearBeam(
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

class _LineClearBeam extends StatelessWidget {
  final double tileWidth;
  final double tileHeight;
  final int cols;
  final int rows;
  final bool isHorizontal;
  final int triggerRow;
  final int triggerCol;

  const _LineClearBeam({
    super.key,
    required this.tileWidth,
    required this.tileHeight,
    required this.cols,
    required this.rows,
    required this.isHorizontal,
    required this.triggerRow,
    required this.triggerCol,
  });

  @override
  Widget build(BuildContext context) {
    final double stepX = tileWidth + tileSpacingGap;
    final double stepY = tileHeight + tileSpacingGap;

    final double triggerLeft = triggerCol * stepX;
    final double triggerTop = triggerRow * stepY;

    final int maxIndex = isHorizontal ? cols : rows;
    final int triggerIndex = isHorizontal ? triggerCol : triggerRow;

    final double fullLength = isHorizontal ? cols * stepX : rows * stepY;
    final double waveLeft = isHorizontal ? 0 : triggerLeft;
    final double waveTop = isHorizontal ? triggerTop : 0;

    final double alignX = isHorizontal
        ? (cols > 1 ? (triggerCol / (cols - 1)) * 2 - 1 : 0)
        : 0;
    final double alignY = !isHorizontal
        ? (rows > 1 ? (triggerRow / (rows - 1)) * 2 - 1 : 0)
        : 0;
    final originAlignment = Alignment(alignX, alignY);

    Widget energyWave = Positioned(
      left: waveLeft,
      top: waveTop,
      width: isHorizontal ? fullLength : tileWidth,
      height: isHorizontal ? tileHeight : fullLength,
      child:
          Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(tileWidth / 2),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.redAccent,
                      Colors.blueAccent,
                      Colors.white,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.9),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: Colors.redAccent.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              )
              .animate()
              .custom(
                duration: 150.ms,
                curve: Curves.easeOutExpo,
                builder: (context, value, child) {
                  return Transform.scale(
                    alignment: originAlignment,
                    scaleX: isHorizontal ? value : 1.0,
                    scaleY: !isHorizontal ? value : 1.0,
                    child: child,
                  );
                },
              )
              .fadeOut(delay: 50.ms, duration: 150.ms),
    );

    final List<Widget> mirages = [];
    for (int i = 0; i < maxIndex; i++) {
      if (i == triggerIndex) continue;

      final double targetLeft = isHorizontal ? i * stepX : triggerLeft;
      final double targetTop = isHorizontal ? triggerTop : i * stepY;
      final double dx = targetLeft - triggerLeft;
      final double dy = targetTop - triggerTop;

      final int distance = (i - triggerIndex).abs();
      final int staggerMs = distance * 15;

      Widget ghost = SvgPicture.asset(
        Emojis.barberPole.svg,
        width: tileWidth,
        height: tileHeight,
      );
      if (!isHorizontal) {
        ghost = Transform.rotate(angle: pi / 2, child: ghost);
      }

      mirages.add(
        Positioned(
          left: triggerLeft,
          top: triggerTop,
          child: ghost
              .animate(delay: Duration(milliseconds: staggerMs))
              .move(
                begin: Offset.zero,
                end: Offset(dx, dy),
                duration: 100.ms,
                curve: Curves.easeOut,
              )
              .scaleXY(begin: 0.5, end: 1.2, duration: 100.ms)
              .fadeOut(delay: 20.ms, duration: 100.ms),
        ),
      );
    }

    return Stack(clipBehavior: Clip.none, children: [energyWave, ...mirages]);
  }
}
