import 'package:flutter/material.dart';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/sounds.dart';
import 'package:provider/provider.dart';

class IconToggle extends StatelessWidget {
  final String imagePath;
  final bool isActive;
  final VoidCallback onTap;

  const IconToggle({
    super.key,
    required this.imagePath,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AudioController>().playSfx(SfxType.buttonTap);
        onTap();
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isActive ? 1.0 : 0.4,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          width: 80,
          height: 80,
        ),
      ),
    );
  }
}
