import 'package:flutter/material.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/dialogs/pause_dialog.dart';
import 'package:grimoji/features/level/widgets/dialogs/purchase_dialog/index.dart';
import 'package:grimoji/features/level/widgets/footer/powerup.dart';
import 'package:grimoji/features/level/powerup_handlers/index.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';
import 'package:provider/provider.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  late LevelState _levelState;
  bool _isPauseDialogOpen = false;

  @override
  void initState() {
    super.initState();
    _levelState = context.read<LevelState>();

    _levelState.gameState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _levelState.gameState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (_levelState.gameState.isPaused && !_isPauseDialogOpen) {
      _showPauseDialog();
    }
  }

  void _showPauseDialog() {
    _isPauseDialogOpen = true;
    final levelNumber = context.read<GameLevel>().number;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showAnimatedDialog(context, PauseDialog(level: levelNumber)).then((_) {
        if (!mounted) return;

        _isPauseDialogOpen = false;

        if (_levelState.gameState.isPaused) {
          _levelState.coordinator.togglePause();
        }
      });
    });
  }

  void _handlePauseTap() {
    if (!_levelState.gameState.isPaused) {
      _levelState.coordinator.togglePause();
    }
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

  Future<void> _handlePowerupTap(BuildContext context, Powerup powerup) async {
    final profile = context.read<ProfileController>();
    final count = profile.getPowerupCount(powerup.id);

    if (count > 0) {
      final handler = PowerupHandlerRegistry.get(powerup.id);
      if (handler != null) {
        profile.updatePowerupCount(powerup.id, -1);
        await handler.execute(context, powerup, _levelState);
      } else {
        _showSnackbar(context);
      }
      return;
    }

    _levelState.pauseTimer();
    try {
      final purchased = await showBoostPurchase(context, powerup);
      if (purchased == true && context.mounted) {
        final handler = PowerupHandlerRegistry.get(powerup.id);
        if (handler != null) {
          profile.updatePowerupCount(powerup.id, -1);
          await handler.execute(context, powerup, _levelState);
        }
      }
    } finally {
      _levelState.resumeTimerOnly();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = context.watch<LevelState>().gameState.isPaused;

    final profile = context.watch<ProfileController>();
    final bottomPowerups = Powerup.bottom;

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
              onTap: _handlePauseTap,
              enableAnimation: false,
            ),
            const SizedBox(width: 12),
            ...bottomPowerups.expand((powerup) {
              final count = profile.getPowerupCount(powerup.id);
              return [
                PowerupBtn(
                  assetPath: powerup.iconPath,
                  count: count,
                  onTap: () => _handlePowerupTap(context, powerup),
                ),
                const SizedBox(width: 12),
              ];
            }).toList()..removeLast(),
          ],
        ),
      ),
    );
  }
}
