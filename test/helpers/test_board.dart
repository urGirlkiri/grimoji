import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'test_level.dart';

class TestBoard {
  static BoardManager create(GameLevel level) {
    final board = BoardManager(level);
    board.initialize();
    return board;
  }

  static BoardManager createDefault() {
    final level = TestLevel.create();
    return create(level);
  }
}
