import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class Chapter1Reactions {
  static final Reaction explosive = Reaction(
    type: ReactionType.explosive,
    triggers: [Emojis.bomb],
    transformations: {
      Emojis.skull: Emojis.bone,
      Emojis.bone: Emojis.ghost,
      Emojis.spider: Emojis.cloud,
    },
    aoeRadius: 1,
  );

  static List<Reaction> get all => [explosive];
} 