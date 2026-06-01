import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/utils/context_data.dart';

class BoardGrid extends StatelessWidget {
  final int gridColumns;
  final int totalTiles;
  final double tWidth;
  final double tHeight;
  final GlobalKey firstTileKey;

  const BoardGrid({
    super.key,
    required this.gridColumns,
    required this.totalTiles,
    required this.tWidth,
    required this.tHeight,
    required this.firstTileKey,
  });

  @override
  Widget build(BuildContext context) {
    final int gridRows = (totalTiles / gridColumns).ceil();
    final palette = context.palette;

    List<Widget> backgrounds = [];

    for (int r = 0; r < gridRows; r++) {
      for (int c = 0; c < gridColumns; c++) {
        final int index = r * gridColumns + c;
        final double leftPixel = (c * tWidth) + (c * tileSpacingGap);
        final double topPixel = (r * tHeight) + (r * tileSpacingGap);

        backgrounds.add(
          Positioned(
            left: leftPixel,
            top: topPixel,
            width: tWidth,
            height: tHeight,
            child: Container(
              key: index == 0 ? firstTileKey : null,
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
            ),
          ),
        );
      }
    }

    return Stack(clipBehavior: Clip.none, children: backgrounds);
  }
}