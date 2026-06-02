import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/game/board/models/tile.dart';
import 'package:grimoji/features/game/board/widgets/tile_grid/tile/tile_content/hint.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

class TileContent extends StatefulWidget {
  final Tile tile;
  final GameEmoji displayEmoji;
  final double tWidth;
  final double tHeight;
  final bool isTouched;

  const TileContent({
    super.key,
    required this.tile,
    required this.displayEmoji,
    required this.tWidth,
    required this.tHeight,
    this.isTouched = false,
  });

  @override
  State<TileContent> createState() => _TileContentState();
}

class _TileContentState extends State<TileContent> with SingleTickerProviderStateMixin {
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
  void didUpdateWidget(covariant TileContent oldWidget) {
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
    final targetScale = widget.tile.isExploding
        ? 0.0
        : widget.tile.isMerging
        ? 0.0
        : widget.tile.isMergePoint
        ? 1.15
        : widget.tile.isTriggered
        ? 1.1
        : widget.isTouched
        ? 1.15
        : 1.0;

    final displayEmoji = widget.tile.morphTarget ?? widget.tile.emoji;
    final reaction = RecipeBook.getReactionFor(displayEmoji);
    final isExplosive =
        reaction != null && reaction.type == ReactionType.explosive;

    final targetOpacity = widget.tile.isExploding && isExplosive ? 0.0 : 1.0;

    return  AnimatedBuilder(
       animation: _shakeController,
      
      builder: (context, child) {
        final shakeVal = _shakeController.value;
        final angle = (shakeVal * 0.2) - 0.1;
        return Transform.rotate(angle: angle, child: child);
      },
      child: AnimatedOpacity(
        opacity: targetOpacity,
        duration: const Duration(milliseconds: 300),
        child: AnimatedScale(
          scale: targetScale,
          duration: Duration(milliseconds: widget.isTouched ? 100 : 200),
          curve: widget.tile.isMergePoint ? Curves.elasticOut : Curves.easeOutBack,
          child: HintNudge(
            isHinting: widget.tile.isHinting,
            current: widget.tile.coordinate,
            partner: widget.tile.hintPartner,
            tileWidth: widget.tWidth,
            tileHeight: widget.tHeight,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                if (widget.tile.isTransmuting) {
                  return RotationTransition(
                    turns: Tween<double>(
                      begin: -0.5,
                      end: 0.0,
                    ).animate(animation),
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
          ),
        ),
      ),
    );
  }
}
