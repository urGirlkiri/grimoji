import 'package:flutter/material.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/utils/context_data.dart';

class BoardGrid extends StatelessWidget {
  final int gridColumns;
  final int totalTiles;
  final double aspectRatio;
  final GlobalKey firstTileKey;

  const BoardGrid({
    super.key,
    required this.gridColumns,
    required this.totalTiles,
    required this.aspectRatio,
    required this.firstTileKey,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridColumns,
        crossAxisSpacing: tileSpacingGap,
        mainAxisSpacing: tileSpacingGap,
        childAspectRatio: aspectRatio,
      ),
      itemCount: totalTiles,
      itemBuilder: (context, tileIndex) {
        return Container(
          key: tileIndex == 0 ? firstTileKey : null,
          decoration: BoxDecoration(
            color: context.palette.twilight.withValues(alpha: 0.38),
            border: Border.all(color: context.palette.dusk, width: 1),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: context.palette.voidBlack.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        );
      },
    );
  }
}