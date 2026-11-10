import 'dart:async';

import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/effect/models/board_effect.dart';

class EffectManager<T extends BoardEffect> {
  final ValueNotifier<List<T>> _notifier = ValueNotifier([]);
  final Duration lifetime;
  final Map<String, Timer> _removalTimers = {};

  EffectManager({this.lifetime = const Duration(milliseconds: 800)});

  void trigger(T effect) {
    _notifier.value = [..._notifier.value, effect];
    _scheduleRemoval(effect);
  }

  void refresh(String id) {
    T? effect;
    for (final e in _notifier.value) {
      if (e.id == id) {
        effect = e;
        break;
      }
    }
    if (effect == null) return;
    _scheduleRemoval(effect);
  }

  void _scheduleRemoval(T effect) {
    _removalTimers[effect.id]?.cancel();
    _removalTimers[effect.id] = Timer(lifetime, () {
      _notifier.value = _notifier.value
          .where((e) => e.id != effect.id)
          .toList();
      _removalTimers.remove(effect.id);
    });
  }

  ValueNotifier<List<T>> get notifier => _notifier;

  List<T> get effects => _notifier.value;

  void dispose() {
    for (final timer in _removalTimers.values) {
      timer.cancel();
    }
    _notifier.dispose();
  }
}
