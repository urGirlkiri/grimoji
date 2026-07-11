import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';

class Content extends StatelessWidget {
  const Content({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.only(
          left: 95,
          right: 95,
          top: 80,
          bottom: 60,
        ),
        decoration: BoxDecoration(
          color: palette.dusk,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: palette.voidBlack.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select a tile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: palette.voidBlack,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap any tile to use the powerup',
                style: TextStyle(fontSize: 14, color: palette.voidBlack),
              ),
              const SizedBox(height: 8),
              // EmojiWidget(assetPath: )
            ],
          ),
        ),
      ),
    );
  }
}
