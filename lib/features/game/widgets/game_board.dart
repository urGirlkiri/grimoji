import 'package:flutter/material.dart';
import 'package:mojingo/config/emojis.dart';
import 'package:mojingo/config/palette.dart';
import 'package:mojingo/widgets/emoji_widget.dart';
import 'package:provider/provider.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    return Center(
      child: AspectRatio(
        aspectRatio: 5 / 8,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: ShapeDecoration(
            color: palette.mist,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double spacing = 2.0;

              final double exactTileWidth =
                  (constraints.maxWidth - (spacing * 4)) / 5;
              final double exactTileHeight =
                  (constraints.maxHeight - (spacing * 7)) / 8;

              final double dynamicRatio = exactTileWidth / exactTileHeight;

              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                  childAspectRatio: dynamicRatio,
                ),
                itemCount: 40,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: palette.twilight.withValues(alpha: 0.38),
                      border: Border.all(color: palette.dusk, width: 1),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: palette.voidBlack.withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: EmojiWidget(
                        assetPath: Emojis.seedling.svg,
                        size: 48,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
