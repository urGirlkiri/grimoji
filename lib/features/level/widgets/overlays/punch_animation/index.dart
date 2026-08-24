import 'package:flutter/material.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/level/widgets/overlays/punch_animation/animation.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class PunchingOverlay extends StatelessWidget {
  static final _log = Logger('PunchingOverlay');

  final Rect boardRect;

  const PunchingOverlay({super.key, required this.boardRect});

  @override
  Widget build(BuildContext context) {
    final levelState = context.read<LevelState>();

    if (levelState.selectedPowerup?.id != 'boxing_glove') {
      return const SizedBox.shrink();
    }

    final start = levelState.powerupIconPosition;
    final target = levelState.powerupTarget;

    if (start == null || target == null || boardRect.isEmpty) {
      _log.warning(
        'Punch animation skipped: start=$start, target=$target, boardRect=$boardRect',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        levelState.completePowerupAnimation();
      });
      return const SizedBox.shrink();
    }

    final targetCenter = _computeTargetCenter(target);
    final tileSize = _computeTileSize();

    return FlyingPunchAnimation(
      startPosition: start,
      targetPosition: targetCenter,
      tileSize: tileSize,
      onImpact: () => levelState.markPowerupImpact(),
      onComplete: () => levelState.completePowerupAnimation(),
    );
  }

  Offset _computeTargetCenter(TileCoordinate target) {
    final tileWidth =
        (boardRect.width - (tileSpacingGap * (BoardManager.cols - 1))) /
        BoardManager.cols;
    final tileHeight =
        (boardRect.height - (tileSpacingGap * (BoardManager.rows - 1))) /
        BoardManager.rows;

    return Offset(
      boardRect.left +
          target.col * (tileWidth + tileSpacingGap) +
          tileWidth / 2,
      boardRect.top +
          target.row * (tileHeight + tileSpacingGap) +
          tileHeight / 2,
    );
  }

  double _computeTileSize() {
    final tileWidth =
        (boardRect.width - (tileSpacingGap * (BoardManager.cols - 1))) /
        BoardManager.cols;
    final tileHeight =
        (boardRect.height - (tileSpacingGap * (BoardManager.rows - 1))) /
        BoardManager.rows;

    return tileWidth > tileHeight ? tileHeight : tileWidth;
  }
}
