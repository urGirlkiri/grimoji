import 'manager.dart';

enum EffectType {
  sparkle,
  lineClear,
  wheelRoll,
  ghostDive,
  powerup,
}

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
