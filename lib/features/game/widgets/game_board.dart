import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 5 / 8,
        child: Container(
          padding: const EdgeInsets.all(8), 
          decoration: ShapeDecoration(
            color: const Color(0xFFA6A6BF),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const double spacing = 2.0;
              
              final double exactTileWidth = (constraints.maxWidth - (spacing * 4)) / 5;
              final double exactTileHeight = (constraints.maxHeight - (spacing * 7)) / 8;
              
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
                      color: const Color(0x60333346),
                      border: Border.all(color: const Color(0xFF535373), width: 1),
                      borderRadius: BorderRadius.circular(4), 
                    ),
                    child: Center(
                      child: DropShadow(
                        blurRadius: 4,
                        offset: const Offset(0, 4),
                        color: const Color(0x660E0E12), 
                        child: SvgPicture.asset(
                          'assets/emojis/svg/1f331.svg',
                          width: 48,
                          height: 48,
                        ),
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

