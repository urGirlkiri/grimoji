import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/utils/context_data.dart';

class LevelComOverlay {
  static OverlayEntry? _currentEntry;

  static OverlayEntry? get currentEntry => _currentEntry;

  static void show(BuildContext context) {
    _currentEntry?.remove();

    _currentEntry = OverlayEntry(
      builder: (context) => _LevelComOverlayWidget(),
    );

    if (_currentEntry != null) {
      Overlay.of(context).insert(_currentEntry!);
    }
  }

  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _LevelComOverlayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    

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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    Text(
                      'LEVEL COMPLETE!',
                      textAlign: TextAlign.center,
                      style: context.theme.textTheme.headlineMedium,
                    ).animate().scale(
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOutBack,
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                    ),
              ),
            ),
          ),

          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: SizedBox(
              width: 250,
              height: 250,
              child: Image.asset(
                'assets/mascot/celebration.webp',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
