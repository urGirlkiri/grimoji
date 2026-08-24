import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/dialogs/purchase_dialog/index.dart';
import 'package:grimoji/features/level/widgets/footer/powerup.dart';
import 'package:grimoji/features/level/widgets/footer/powerup_bump.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/index.dart';
import 'package:grimoji/features/profile/controller.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/custom/app_icon.dart';
import 'package:provider/provider.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  late LevelState _levelState;

  @override
  void initState() {
    super.initState();
    _levelState = context.read<LevelState>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _handlePauseTap() {
    if (!_levelState.gameState.isPaused) {
      _levelState.coordinator.togglePause();
    }
  }

  void _showSnackbar(BuildContext context) {
    final scale = context.globalScale;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: palette.dusk,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(
          horizontal: 24 * scale,
          vertical: 125 * scale,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          'Coming Soon',
          textAlign: TextAlign.center,
          style: context.theme.textTheme.bodyMedium?.copyWith(
            color: palette.moonlight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _handlePowerupTap(BuildContext context, Powerup powerup) async {
    if (_levelState.gameState.isFeverTime) return;
    if (_levelState.isTrailer) {
      final handler = PowerupHandlerRegistry.get(powerup.id);
      if (handler != null) {
        await handler.execute(context, powerup, _levelState);
      }
      return;
    }

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
    final isTrailer = _levelState.isTrailer;

    final profile = context.watch<ProfileController>();
    final bottomPowerups = Powerup.bottom;

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
            if (!isTrailer)
              AppIcon(
                fileName: isPaused ? 'resume' : 'pause',
                size: 68,
                onTap: _handlePauseTap,
                enableAnimation: false,
              ),
            if (!isTrailer) const SizedBox(width: 12),
            ...bottomPowerups.expand((powerup) {
              final count = isTrailer ? 0 : profile.getPowerupCount(powerup.id);
              final btnKey = _levelState.powerupBtnKeys.putIfAbsent(
                powerup.id,
                () => GlobalKey(),
              );
              return [
                PowerupBump(
                  token: _levelState.bumpPowerupToken(powerup.id),
                  child: PowerupBtn(
                    key: btnKey,
                    assetPath: powerup.iconPath,
                    count: count,
                    onTap: () => _handlePowerupTap(context, powerup),
                  ),
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