import 'package:grimoji/features/match/board/effect/manager.dart';
import 'package:grimoji/features/match/board/effect/models/board_effect.dart';
import 'package:grimoji/features/match/board/effect/models/effect_type.dart';

class EffectRegistry {
  static final Map<EffectType, EffectManager> _managers = {};

  static void register(EffectType type, EffectManager manager) {
    _managers[type] = manager;
  }

  static void trigger(EffectType type, BoardEffect effect) {
    final manager = _managers[type];
    if (manager != null) {
      manager.trigger(effect);
    }
  }

  static EffectManager? getManager(EffectType type) {
    return _managers[type];
  }

  static void disposeAll() {
    for (final manager in _managers.values) {
      manager.dispose();
    }
    _managers.clear();
  }
}
