import 'dart:math';

import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/difficulty.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/models/action_type.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/detectors/hint/index.dart';

class PrankBehavior extends EmojiBehavior {
  static final emoji = Emojis.impSmile;

  @override
  bool get isIntrusive => true;

  @override
  Future<List<BehaviorAction>> onTurnEndWithBoard(
    int x,
    int y,
    List<List<Tile>> board,
    GameLevel level,
  ) async {
    final probability = Random().nextDouble();

    if (probability >= LevelDifficulty.prankChanceFor(level.number)) {
      return [];
    }

    final hintMove = await HintDetector.findBestMove(
      grid: board,
      targetEmoji: level.targetEmoji,
    );

    if (hintMove == null) {
      return [];
    }

    final target = hintMove[2];

    return [
      BehaviorAction(type: ActionType.spawnPoop, x: target.row, y: target.col),
    ];
  }
}
