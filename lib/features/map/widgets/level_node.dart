import 'package:flutter/material.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/level/widgets/dialogs/cauldron_dialog.dart';
import 'package:grimoji/features/level/widgets/dialogs/start_dialog/index.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';
import 'package:grimoji/widgets/custom/star_icon.dart';

class LevelNode extends StatelessWidget {
  final GameLevel level;
  final int stars;
  final double cacheSize;
  final bool isUnlocked;

  const LevelNode({
    super.key,
    required this.level,
    required this.stars,
    required this.cacheSize,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    if (!isUnlocked) return const SizedBox.shrink();

    const double nodeSize = 85.0;
    const double fontSize = 28.0;

    return RepaintBoundary(
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
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
                cacheWidth: cacheSize.round(),
                cacheHeight: cacheSize.round(),
              ),
              if (stars > 0) Positioned(bottom: 10, child: _StarCluster(stars)),
              Positioned(
                top: stars > 0 ? 18 : null,
                child: Text(
                  level.number.toString(),
                  style: context.theme.textTheme.titleLarge?.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLevelDialog(BuildContext context) {
    context.readAudio.playSfx(SfxType.buttonTap);

    final profile = context.readProfile;
    profile.checkCauldronRegen();

    if (profile.cauldrons <= 0) {
      showAnimatedDialog(context, const CauldronDialog());
    } else {
      showAnimatedDialog(context, LevelStartDialog(level: level));
    }
  }
}

class _StarCluster extends StatelessWidget {
  final int count;
  const _StarCluster(this.count);

  @override
  Widget build(BuildContext context) {
    if (count == 1) return const StarIcon(size: 24);

    if (count == 2) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [StarIcon(size: 24), StarIcon(size: 24)],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const StarIcon(size: 24),
        Transform.translate(
          offset: const Offset(0, -6),
          child: const StarIcon(size: 26),
        ),
        const StarIcon(size: 24),
      ],
    );
  }
}
