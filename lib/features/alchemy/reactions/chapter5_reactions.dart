import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class Chapter5Reactions {
  
  static final Reaction cosmic = Reaction(
    type: ReactionType.cosmic,
    triggers: [Emojis.comet, Emojis.glowingStar],
    transformations: {
      Emojis.sparkles: Emojis.star,
      Emojis.star: Emojis.glowingStar,
      Emojis.crystalBall: Emojis.die,
      Emojis.alien: Emojis.alienMonster,
    },
    aoeRadius: 2,
  );

  static List<Reaction> get all => [cosmic];
}