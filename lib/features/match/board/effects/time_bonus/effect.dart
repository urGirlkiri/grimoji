import 'package:flutter/material.dart';
import 'package:grimoji/features/match/board/effect/manager.dart';

class TimeBonusEffect extends BoardEffect {
  final Offset position;
  final int amount;

  TimeBonusEffect({
    required this.position,
    required this.amount,
  }) : super();
}
