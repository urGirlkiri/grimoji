import 'package:grimoji/features/match/board/models/coordinate.dart';
import 'package:grimoji/features/match/model/collected_emoji.dart';

class DetonationStepResult {
  final Set<TileCoordinate> destroyed;
  final Set<TileCoordinate> transformed;
  final List<CollectedEmoji> collectedEmojis;
  final bool hasChainReaction;

  DetonationStepResult({
    required this.destroyed,
    required this.transformed,
    required this.collectedEmojis,
    required this.hasChainReaction,
  });
}
