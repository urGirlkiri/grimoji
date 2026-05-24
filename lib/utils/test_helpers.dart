import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/game/engines/game_engine.dart';

class TestHelpers {
  static void genDeadLockGrid(GameEngine engine) {
    final colors = [Emojis.fire, Emojis.rock, Emojis.droplet, Emojis.alien];
    for (int r = 0; r < engine.grid.length; r++) {
      for (int c = 0; c < engine.grid[0].length; c++) {
        engine.grid[r][c].emoji = colors[(r + 2 * c) % 4];
      }
    }
  }
}