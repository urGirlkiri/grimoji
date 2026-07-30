import 'package:flutter/material.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/level/widgets/dialogs/cauldron_dialog.dart';
import 'package:grimoji/features/level/widgets/dialogs/start_dialog/index.dart';
import 'package:grimoji/features/map/widgets/level_nodes/node/star_cluster.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:grimoji/widgets/animations/dialog.dart';

class LevelNode extends StatelessWidget {
  final GameLevel level;
  final int stars;
  final int crimsonStars;
  final double cacheSize;
  final bool isUnlocked;

  const LevelNode({
    super.key,
    required this.level,
    required this.stars,
    this.crimsonStars = 0,
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
              if (stars > 0)
                Positioned(
                  bottom: 10,
                  child: StarCluster(stars, crimsonStars: crimsonStars),
                ),
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

