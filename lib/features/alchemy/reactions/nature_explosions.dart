import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class NatureReactions {
  static final Reaction burning = Reaction(
    type: ReactionType.burning,
    triggers: [Emojis.fire],
    transformations: {
      Emojis.evergreenTree: Emojis.fire,
      Emojis.rock: Emojis.gemStone,
    },
    aoeRadius: 1,
  );

  static List<Reaction> get all => [burning];
}
