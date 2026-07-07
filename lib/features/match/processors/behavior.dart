import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/state.dart';

class BehaviorProcessor {
  final GameEngine engine;
  final GameState state;

  BehaviorProcessor({
    required this.engine,
    required this.state,
  });

  Future<bool> executeBehavior() async {
    return false;
  }
}
