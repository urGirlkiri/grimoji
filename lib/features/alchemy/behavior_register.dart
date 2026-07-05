import 'dart:math';

import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/alchemy/behaviors/clear.dart';
import 'package:grimoji/features/alchemy/behaviors/dive.dart';
import 'package:grimoji/features/alchemy/behaviors/swallow.dart';
import 'package:grimoji/features/alchemy/behaviors/virus.dart';
import 'package:grimoji/features/alchemy/behaviors/prank.dart';
import 'package:grimoji/features/alchemy/behaviors/wheel.dart';

class BehaviorRegister {
  static final _random = Random();

  static final Map<GameEmoji, EmojiBehavior Function()> _behaviors = {
    VirusBehavior.emoji: () => VirusBehavior(),
    PrankBehavior.emoji: () => PrankBehavior(),
    SwallowBehavior.emoji: () => SwallowBehavior(),
    ClearBehavior.emoji: () => ClearBehavior(isHorizontal: _random.nextBool()),
    WheelBehavior.emoji: () => WheelBehavior(),
    DiveBehavior.emoji: () => DiveBehavior(),
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

  static Set<GameEmoji> get intrusiveEmojis => _behaviors.entries
      .where((e) => e.value().isIntrusive)
      .map((e) => e.key)
      .toSet();
}
