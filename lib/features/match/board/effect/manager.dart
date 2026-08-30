import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/effect/models/board_effect.dart';

class EffectManager<T extends BoardEffect> {
  final ValueNotifier<List<T>> _notifier = ValueNotifier([]);
  final Duration lifetime;

  EffectManager({this.lifetime = const Duration(milliseconds: 800)});

  void trigger(T effect) {
    _notifier.value = [..._notifier.value, effect];
    Future.delayed(lifetime, () {
      _notifier.value = _notifier.value.where((e) => e.id != effect.id).toList();
    });
  }

  ValueNotifier<List<T>> get notifier => _notifier;

  List<T> get effects => _notifier.value;

  void dispose() {
    _notifier.dispose();
  }
}
