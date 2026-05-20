import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/game/board/widgets/hit_nudge.dart';
import 'package:grimoji/features/game/board/widgets/tile_widget/explosion.dart';
import 'package:grimoji/features/game/board/widgets/tile_widget/transmutation.dart';
import 'package:grimoji/features/game/model/tile.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/widgets/emoji_widget.dart';
import 'package:provider/provider.dart';

class TileWidget extends StatefulWidget {
  const TileWidget({
    super.key,
    required this.tile,
    required this.leftPixel,
    required this.topPixel,
    required this.tWidth,
    required this.tHeight,
    required this.emoji,
    this.isTouched = false,
  });

  final Tile tile;
  final double leftPixel;
  final double topPixel;
  final double tWidth;
  final double tHeight;
  final GameEmoji? emoji;
  final bool isTouched;

  @override
  State<TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<TileWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(covariant TileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tile.isTriggered && !oldWidget.tile.isTriggered) {
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedPositioned(
        duration: swapAnimationTime,
        curve: Curves.easeOutCubic,
        left: widget.leftPixel,
        top: widget.topPixel,
        width: widget.tWidth,
        height: widget.tHeight,
        child: Center(child: _buildTileContent(context)),
      ),
    );
  }

  Widget _buildTileContent(BuildContext context) {
    if (widget.tile.hasFlown) {
      return const SizedBox.shrink();
    }

    final palette = context.read<Palette>();

    final displayEmoji = widget.tile.morphTarget ?? widget.tile.emoji;

    Widget emojiUI = AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation) {
        if (widget.tile.isTransmuting) {
          return RotationTransition(
            turns: Tween<double>(begin: -0.5, end: 0.0).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
          );
        }
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        );
      },
      child: EmojiWidget.svg(
        key: ValueKey(displayEmoji.visual),
        path: displayEmoji.svg,
        size: widget.tWidth * 0.8,
      ),
    );

    emojiUI = HintNudge(
      isHinting: widget.tile.isHinting,
      current: widget.tile.coordinate,
      partner: widget.tile.hintPartner,
      tileWidth: widget.tWidth,
      tileHeight: widget.tHeight,
      child: emojiUI,
    );

    final reaction = RecipeBook.getReactionFor(displayEmoji);
    final isExplosive =
        reaction != null && reaction.type == ReactionType.explosive;

    double targetScale = 1.0;
    double targetOpacity = 1.0;

    if (widget.tile.isExploding) {
      targetScale = 0.0;
      if (isExplosive) targetOpacity = 0.0;
    } else if (widget.tile.isMerging) {
      targetScale = 0.0;
    } else if (widget.tile.isMergePoint) {
      targetScale = 1.3;
    } else if (widget.tile.isTriggered) {
      targetScale = 1.1;
    } else if (widget.isTouched) {
      targetScale = 1.15;
    }

    Widget scaledEmoji = AnimatedScale(
      scale: targetScale,
      duration: Duration(milliseconds: widget.isTouched ? 100 : 200),
      curve: widget.tile.isMergePoint ? Curves.elasticOut : Curves.easeOutBack,
      child: emojiUI,
    );

    Widget fadingEmoji = AnimatedOpacity(
      opacity: targetOpacity,
      duration: const Duration(milliseconds: 50),
      child: scaledEmoji,
    );

    if (widget.tile.isTriggered) {
      fadingEmoji = AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final shakeValue = _shakeController.value;
          final angle = (shakeValue * 0.2) - 0.1;
          return Transform.rotate(angle: angle, child: child);
        },
        child: fadingEmoji,
      );
    }

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        fadingEmoji,
        if (widget.tile.isExploding)
          isExplosive
              ? TileExplosion(size: widget.tWidth)
              : EmojiWidget.lottie(
                  path: widget.tile.emoji.lottie,
                  size: widget.tWidth * 0.8,
                ),
        if (widget.tile.isTransmuting)
          TileTransmutation(size: widget.tWidth, color: palette.trueWhite),
      ],
    );
  }
}


