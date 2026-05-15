import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/game/controller.dart';

class TestHelpers {
  static void genDeadLockGrid(GameController controller) {
    final colors = [Emojis.fire, Emojis.rock, Emojis.droplet, Emojis.alien];
    for (int r = 0; r < controller.getRowCount(); r++) {
      for (int c = 0; c < controller.getColCount(); c++) {
        controller.grid[r][c].emoji = colors[(r + 2 * c) % 4];
      }
    }
  }
}