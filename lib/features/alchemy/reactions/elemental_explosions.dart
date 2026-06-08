import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class ElementalReactions {
  static final Reaction explosive = Reaction(
    type: ReactionType.explosive,
    triggers: [Emojis.bomb],
    transformations: {
      Emojis.ocean: Emojis.salt,
      Emojis.cloud: Emojis.rainbow,
      Emojis.rock: Emojis.volcano,
    },
    aoeRadius: 1,
  );

  static List<Reaction> get all => [explosive];
}