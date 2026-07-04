import 'package:flutter/material.dart';
import 'manager.dart';

class EffectOverlay<T extends BoardEffect> extends StatelessWidget {
  final EffectManager<T> manager;
  final Widget Function(T effect) builder;

  const EffectOverlay({
    super.key,
    required this.manager,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<T>>(
      valueListenable: manager.notifier,
      builder: (context, effects, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: effects.map((effect) => builder(effect)).toList(),
        );
      },
    );
  }
}
