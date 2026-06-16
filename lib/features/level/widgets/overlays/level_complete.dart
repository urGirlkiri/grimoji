import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/features/level/widgets/overlays/mascot.dart';
import 'package:grimoji/utils/context_data.dart';

class LevelComOverlay extends StatelessWidget {
  const LevelComOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: palette.midnight.withValues(alpha: 0.8)),
          ),

          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'LEVEL COMPLETE!',
                textAlign: TextAlign.center,
                style: context.theme.textTheme.headlineMedium
              )
                  .animate()
                  .scale(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutBack,
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                  ),
            ),
          ),

          const Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: WavingMascot(),
          ),
        ],
      ),
    );
  }
}
