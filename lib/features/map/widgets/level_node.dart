import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mojingo/config/audio/audio_controller.dart';
import 'package:mojingo/config/audio/sounds.dart';
import 'package:provider/provider.dart';

class LevelNode extends StatelessWidget {
  final int level;

  const LevelNode({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.sizeOf(context).width > 600;

    final double nodeSize = isLargeScreen ? 85.0 : 45.0;

    final double fontSize = isLargeScreen ? 28.0 : 16.0;

    return InkWell(
      onTap: () => _showLevelDialog(context),
      child: SizedBox(
        width: 100,
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              "assets/images/map/level.png",
              fit: BoxFit.contain,
              width: nodeSize,
              height: nodeSize,
            ),
            Text(
              "$level",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelDialog(BuildContext context) {
    final audioController = context.read<AudioController>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Level $level"),
          content: const Text("Ready to play this level?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              child: const Text("Play"),
              onPressed: () {
                audioController.playSfx(SfxType.buttonTap);

                GoRouter.of(context).go('/play/session/$level');
              },
            ),
          ],
        );
      },
    );
  }
}
