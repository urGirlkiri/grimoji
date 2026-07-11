import 'package:flutter/material.dart';
import 'package:grimoji/utils/context_data.dart';

class Content extends StatelessWidget {
  const Content({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: palette.trueWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: palette.voidBlack.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                style: TextStyle(fontSize: 14, color: palette.voidBlack,)
              ),
            ],
          ),
        ),
      ),
    );
  }
}
