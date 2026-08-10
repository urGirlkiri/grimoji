import 'package:flutter/foundation.dart';

class MarketScrollController extends ValueNotifier<int> {
  MarketScrollController() : super(0);

  void scrollToDailyReward() => value++;
}
