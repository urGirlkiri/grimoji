import 'package:flutter/material.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/palette.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/dialogs/pause_dialog.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';
import 'package:grimoji/widgets/custom/emoji_widget.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class Foooter extends StatelessWidget {
  final Logger _log = Logger('Foooter');
  Foooter({super.key});

  Palette get palette => Palette();

  void _handlePauseTap(BuildContext context) {
    _log.info('Pause btn tapped. Toggling pause state.');

    final levelState = context.read<LevelState>();
    levelState.togglePause();

    final levelNumber = context.read<GameLevel>().number;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: palette.voidBlack.withValues(alpha: 0.7),
      builder: (dialogContext) => PauseDialog(level: levelNumber),
    ).then((_) {
      if (context.mounted) {
        _log.info('Pause dialog closed. Toggling pause state again.');
        levelState.togglePause();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = context.watch<LevelState>().isPaused;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShapeDecoration(
        color: palette.mist,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPowerUpBtn(
              isPaused
                  ? 'assets/icons/app/resume.png'
                  : 'assets/icons/app/pause.png',
              isSmall: true,
              onTap: () => _handlePauseTap(context),
            ),
            const SizedBox(width: 12),
            _buildPowerUpBtn(Emojis.crystalBall.svg),
            const SizedBox(width: 12),
            _buildPowerUpBtn(Emojis.testTube.svg),
            const SizedBox(width: 12),
            _buildPowerUpBtn(Emojis.flyingDisc.svg),
            const SizedBox(width: 12),
            _buildPowerUpBtn(Emojis.comet.svg),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerUpBtn(
    String assetPath, {
    bool isSmall = false,
    VoidCallback? onTap,
  }) {
    double size = isSmall ? 60 : 70;
    double iconSize = isSmall ? 60 : 50;

    if (assetPath.startsWith('assets/icons/app/')) {
      final fileName = assetPath.split('/').last.replaceAll('.png', '');
      return AppIcon(
        fileName: fileName, 
        size: iconSize + 8,
         onTap: onTap,
         enableAnimation: false,
        );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(
          color: palette.mist,
          shape: CircleBorder(side: BorderSide(width: 3, color: palette.dusk)),
          shadows: [
            BoxShadow(
              color: palette.voidBlack,
              blurRadius: 1,
              offset: Offset(1, 6),
            ),
          ],
        ),
        child: Center(
          child: EmojiWidget.svg(path: assetPath, size: iconSize,)
        ),
      ),
    );
  }
}
