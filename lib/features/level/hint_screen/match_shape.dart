import 'package:flutter/material.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/utils/math.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';

enum ShapeType { twoByTwo, lShape, tShape, line }

class MatchShape extends StatelessWidget {
  const MatchShape({super.key, required this.shape, required this.recipe});
  final ShapeType shape;
  final Recipe recipe;

  GameEmoji get _tileEmoji => recipe.ingredient;

  List<List<bool>> _shapeGrid() {
    switch (shape) {
      case ShapeType.twoByTwo:
        return [
          [true, true],
          [true, true],
        ];
      case ShapeType.lShape:
        return [
          [true, false],
          [true, false],
          [true, true],
        ];
      case ShapeType.tShape:
        return [
          [true, true, true],
          [false, true, false],
          [false, true, false],
        ];
      case ShapeType.line:
        return List.generate(recipe.requiredAmount, (_) => [true]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final grid = _shapeGrid();
    final rows = grid.length;
    final cols = grid[0].length;

    return Transform.rotate(
      angle: degToRad(shape == ShapeType.line ? 0 : -15),
      child: Column(
        children: List.generate(rows, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(cols, (col) {
              final hasTile = grid[row][col];
              if (!hasTile) {
                return const SizedBox(width: 48, height: 48);
              }
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: palette.twilight.withValues(alpha: .8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: palette.magicCyan.withValues(alpha: .5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: palette.magicCyan.withValues(alpha: .2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: EmojiWidget.lottie(
                    path: _tileEmoji.lottie,
                    size: 48 * context.globalScale,
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}
