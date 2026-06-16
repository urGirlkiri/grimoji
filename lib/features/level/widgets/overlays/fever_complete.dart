import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/features/level/widgets/overlays/mascot.dart';
import 'package:grimoji/utils/context_data.dart';

class FeverComOverlay extends StatelessWidget {
  const FeverComOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return IgnorePointer(
      ignoring: true,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(color: palette.midnight.withValues(alpha: 0.7)),
          ),

          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Diabolical',
                style: context.theme.textTheme.headlineMedium,
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.1, 1.1),
                  ),
            ),
          ),

          Positioned(
            top: 160,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Target Crafted',
                style: context.theme.textTheme.bodyMedium,
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scale(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutBack,
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.1, 1.1),
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
