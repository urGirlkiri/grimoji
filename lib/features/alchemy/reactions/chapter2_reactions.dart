import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class Chapter2Reactions {
  static final Reaction freezing = Reaction(
    type: ReactionType.freezing,
    triggers: [Emojis.snowflake],
    transformations: {
      Emojis.droplet: Emojis.melting,
      Emojis.ocean: Emojis.melting,
      Emojis.fire: Emojis.droplet,
      Emojis.leafyGreen: Emojis.fallenLeaf,
      Emojis.herb: Emojis.fallenLeaf,
    },
    aoeRadius: 1,
  );

  static List<Reaction> get all => [freezing];
}