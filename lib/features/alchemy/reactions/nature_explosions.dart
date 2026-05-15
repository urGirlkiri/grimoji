import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class NatureReactions extends Reaction {
  NatureReactions() : super(
    type: ReactionType.burning,
    triggers: [Emojis.fire],
    transformations: _transformations,
  );

  static const Map<GameEmoji, GameEmoji> _transformations = {
    Emojis.evergreenTree: Emojis.fire,
    Emojis.rock: Emojis.gemStone,
  };
}
