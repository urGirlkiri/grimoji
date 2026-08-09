import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/cauldron/game/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class FireOverlay extends StatefulWidget {
  final CauldronGame game;
  const FireOverlay({super.key, required this.game});

  @override
  State<FireOverlay> createState() => _FireOverlayState();
}

class _FireOverlayState extends State<FireOverlay> {
  double _y = 0;
  static const double fireSize = 150;
  static const double fireSpacing = 70;

  @override
  void initState() {
    super.initState();
    _scheduleUpdate();
  }

  void _scheduleUpdate() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePosition());
  }

  void _updatePosition() {
    if (!mounted) return;
    try {
      const double outOfBoundsWorldY = 6.0;

      final pos = widget.game.camera.localToGlobal(
        Vector2(0, outOfBoundsWorldY),
      );

      if (pos.y != _y && pos.y > 0) {
        setState(() {
          _y = pos.y;
        });
      }
    } catch (_) {}

    if (_y <= 0) {
      Future.delayed(const Duration(milliseconds: 100), _scheduleUpdate);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_y <= 0) {
      return const Positioned(top: -1000, child: SizedBox.shrink());
    }

    final double scaledFireSize = fireSize * context.globalScale;
    final double scaledSpacing = fireSpacing * context.globalScale;
    final double ySpace = context.isLargeScreen ? 60 : 90;
    final double scaledYOffset = ySpace * context.globalScale;

    return Positioned(
      top: _y - scaledYOffset,
      left: -100,
      right: -100,
      height: scaledFireSize,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int dynamicFireCount = (constraints.maxWidth / scaledSpacing)
              .ceil();

          return Stack(
            clipBehavior: Clip.none,
            children: List.generate(
              dynamicFireCount,
              (index) => Positioned(
                left: index * scaledSpacing,
                child: EmojiWidget.lottie(
                  emoji: Emojis.fire,
                  size: scaledFireSize,
                  animate: true,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
