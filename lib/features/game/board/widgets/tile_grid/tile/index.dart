import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/game/board/widgets/hit_nudge.dart';
import 'package:grimoji/features/game/board/widgets/tile_grid/tile/explosion.dart';
import 'package:grimoji/features/game/board/widgets/tile_grid/tile/match.dart';
import 'package:grimoji/features/game/board/models/tile.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

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
    return AnimatedPositioned(
      duration: swapAnimationTime,
      curve: Curves.easeOutCubic,
      left: widget.leftPixel,
      top: widget.topPixel,
      width: widget.tWidth,
      height: widget.tHeight,
      child: RepaintBoundary(child: Center(child: _buildTileContent(context))),
    );
  }

  Widget _buildTileContent(BuildContext context) {
    if (widget.tile.hasFlown) {
      return const SizedBox.shrink();
    }

    final displayEmoji = widget.tile.morphTarget ?? widget.tile.emoji;
    final emojiUI = _buildEmoji(displayEmoji);
    final scaledEmoji = _buildScaledEmoji(emojiUI);
    final fadingEmoji = _buildFadingEmoji(scaledEmoji);
    final shakingEmoji = _buildShakingEmoji(fadingEmoji);

    return _buildOverlayEffects(shakingEmoji, displayEmoji);
  }

  Widget _buildEmoji(GameEmoji displayEmoji) {
    return HintNudge(
      isHinting: widget.tile.isHinting,
      current: widget.tile.coordinate,
      partner: widget.tile.hintPartner,
      tileWidth: widget.tWidth,
      tileHeight: widget.tHeight,
      child: AnimatedSwitcher(
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
      ),
    );
  }

  Widget _buildScaledEmoji(Widget emojiUI) {
    final targetScale = _calculateTargetScale();
    return AnimatedScale(
      scale: targetScale,
      duration: Duration(milliseconds: widget.isTouched ? 100 : 200),
      curve: widget.tile.isMergePoint ? Curves.elasticOut : Curves.easeOutBack,
      child: emojiUI,
    );
  }

  double _calculateTargetScale() {
    if (widget.tile.isExploding) return 0.0;
    if (widget.tile.isMerging) return 0.0;
    if (widget.tile.isMergePoint) return 1.3;
    if (widget.tile.isTriggered) return 1.1;
    if (widget.isTouched) return 1.15;
    return 1.0;
  }

  Widget _buildFadingEmoji(Widget scaledEmoji) {
    final displayEmoji = widget.tile.morphTarget ?? widget.tile.emoji;
    final reaction = RecipeBook.getReactionFor(displayEmoji);
    final isExplosive =
        reaction != null && reaction.type == ReactionType.explosive;

    final targetOpacity = widget.tile.isExploding && isExplosive ? 0.0 : 1.0;

    return AnimatedOpacity(
      opacity: targetOpacity,
      duration: const Duration(milliseconds: 50),
      child: scaledEmoji,
    );
  }

  Widget _buildShakingEmoji(Widget fadingEmoji) {
    if (!widget.tile.isTriggered) return fadingEmoji;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shakeValue = _shakeController.value;
        final angle = (shakeValue * 0.2) - 0.1;
        return Transform.rotate(angle: angle, child: child);
      },
      child: fadingEmoji,
    );
  }

  Widget _buildOverlayEffects(
    Widget shakingEmoji,
    GameEmoji displayEmoji,
  ) {
    final palette = context.palette;
    final reaction = RecipeBook.getReactionFor(displayEmoji);
    final isExplosive =
        reaction != null && reaction.type == ReactionType.explosive;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        shakingEmoji,
        widget.tile.isExploding
            ? isExplosive
                  ? TileExplosion(size: widget.tWidth)
                  : TileMatch(size: widget.tWidth, color: palette.mist)
            : SizedBox(),

        if (widget.tile.isTransmuting)
          EmojiWidget.lottie(
            path: widget.tile.emoji.lottie,
            size: widget.tWidth * 0.8,
          ),
      ],
    );
  }
}
