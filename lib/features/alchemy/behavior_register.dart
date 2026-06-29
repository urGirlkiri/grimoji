import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/behaviors/clear.dart';
import 'package:grimoji/features/alchemy/behaviors/swallow.dart';
import 'package:grimoji/features/alchemy/behaviors/virus.dart';
import 'package:grimoji/features/alchemy/behaviors/prank.dart';
import 'package:grimoji/features/alchemy/behaviors/wheel.dart';

class BehaviorRegister {
  static final Map<GameEmoji, EmojiBehavior Function()> _behaviors = {
    Emojis.microbe: () => VirusBehavior(),
    Emojis.impSmile: () => PrankBehavior(),
    Emojis.hole: () => SwallowBehavior(),
    Emojis.barberPole: () => ClearBehavior(isHorizontal: true),
    Emojis.wheel: () => WheelBehavior(),
  };

  static EmojiBehavior? getBehaviorFor(GameEmoji emoji) {
    final builder = _behaviors[emoji];
    return builder != null ? builder() : null;
  }

  static bool hasBehavior(GameEmoji emoji) {
    return _behaviors.containsKey(emoji);
  }

  static List<GameEmoji> getAllEmojisWithBehaviors() {
    return _behaviors.keys.toList();
  }
}
