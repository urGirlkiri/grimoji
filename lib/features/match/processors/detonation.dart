import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/state.dart';

class DetonationProcessor {
  final GameEngine engine;
  final GameState state;

  DetonationProcessor({required this.engine, required this.state});

  Future<bool> executeDetonation() async {
    final result = engine.processDetonationStep();
    return result.destroyed.isNotEmpty ||
        result.transformed.isNotEmpty ||
        result.collectedEmojis.isNotEmpty ||
        result.hasChainReaction;
  }
}
