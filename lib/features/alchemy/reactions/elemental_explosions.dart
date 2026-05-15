import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class ElementalReactions extends Reaction {
  ElementalReactions() : super(
    type: ReactionType.explosive,
    triggers: [Emojis.bomb],
    transformations: _transformations,
  );

  static const Map<GameEmoji, GameEmoji> _transformations = {
    Emojis.ocean: Emojis.salt,
    Emojis.rock: Emojis.volcano,
    Emojis.cloud: Emojis.rainbow,
  };
}