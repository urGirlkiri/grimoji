import 'package:grimoji/features/match/models/collected_emoji.dart';
import 'package:grimoji/features/match/types.dart';

class DetonationStepResult {
  final TileSet destroyed;
  final TileSet transformed;
  final List<CollectedEmoji> collectedEmojis;
  final bool hasChainReaction;

  DetonationStepResult({
    required this.destroyed,
    required this.transformed,
    required this.collectedEmojis,
    required this.hasChainReaction,
  });
}
