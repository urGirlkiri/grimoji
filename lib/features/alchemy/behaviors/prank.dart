import 'dart:math';

import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/models/action_type.dart';
import 'package:grimoji/features/alchemy/models/behavior_action.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/detectors/hint.dart';
import 'package:logging/logging.dart';

class PrankBehavior extends EmojiBehavior {
  static final emoji = Emojis.impSmile;
  static final Logger _log = Logger('PrankBehavior');

  @override
  bool get isIntrusive => true;

  static const double randomChance = 1;

  @override
  Future<List<BehaviorAction>> onTurnEndWithBoard(
    int x,
    int y,
    List<List<Tile>> board,
    GameLevel level,
  ) async {
    _log.info('At ($x, $y): probability check');
    final probability = Random().nextDouble();
    _log.info(
      'At ($x, $y): probability check: $probability >= $randomChance = ${probability >= randomChance}',
    );

    if (probability >= randomChance) {
      _log.info('At ($x, $y): probability check failed, no action');
      return [];
    }

    _log.info('At ($x, $y): finding hint move');
    final hintMove = await HintDetector.findBestMove(
      grid: board,
      targetEmoji: level.targetEmoji,
    );

    if (hintMove == null) {
      _log.info('At ($x, $y): no hint move found');
      return [];
    }

    _log.info(
      'At ($x, $y): hint move found at (${hintMove[0].row}, ${hintMove[0].col}) -> (${hintMove[1].row}, ${hintMove[1].col})',
    );

    final target = hintMove[0];
    _log.info(
      'At ($x, $y): selected hint partner (${target.row}, ${target.col}) for poop transmutation',
    );

    return [
      BehaviorAction(type: ActionType.spawnPoop, x: target.row, y: target.col),
    ];
  }
}
