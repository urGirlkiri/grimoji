import 'package:flutter/material.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/dialogs/pause_dialog.dart';
import 'package:grimoji/features/level/widgets/footer/powerup.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';
import 'package:provider/provider.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  void _handlePauseTap(BuildContext context) {
    final levelState = context.read<LevelState>();
    levelState.togglePause();

    final levelNumber = context.read<GameLevel>().number;

    showAnimatedDialog(context, PauseDialog(level: levelNumber)).then((_) {
      if (context.mounted) {
        levelState.togglePause();
      }
    });
  }

  void _showSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: context.palette.dusk,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          'Coming Soon',
          textAlign: TextAlign.center,
          style: context.theme.textTheme.bodyMedium?.copyWith(
            color: context.palette.moonlight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = context.watch<LevelState>().isPaused;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: context.palette.mist,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppIcon(
              fileName: isPaused ? 'resume' : 'pause',
              size: 68,
              onTap: () => _handlePauseTap(context),
              enableAnimation: false,
            ),
            const SizedBox(width: 12),
            PowerupBtn(
              assetPath: Emojis.hourglassNotDone.svg,
              onTap: () {
                _showSnackbar(context);
              },
            ),
            const SizedBox(width: 12),
            PowerupBtn(
              assetPath: Emojis.testTube.svg,
              onTap: () {
                _showSnackbar(context);
              },
            ),
            const SizedBox(width: 12),
            PowerupBtn(
              assetPath: Emojis.boxingGlove.svg,
              onTap: () {
                _showSnackbar(context);
              },
            ),
            const SizedBox(width: 12),
            PowerupBtn(
              assetPath: Emojis.flyingSaucer.svg,
              onTap: () {
                _showSnackbar(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
