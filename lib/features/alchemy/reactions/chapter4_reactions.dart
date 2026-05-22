import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class Chapter4Reactions {
  
  static final Reaction electric = Reaction(
    type: ReactionType.electric,
    triggers: [Emojis.electricity, Emojis.cloudWithLightning],
    transformations: {
      Emojis.blackBird: Emojis.poultryLeg, 
      Emojis.bird: Emojis.poultryLeg,
      Emojis.eagle: Emojis.poultryLeg,
       Emojis.poultryLeg: Emojis.bone,
      Emojis.robot: Emojis.collision, 
      Emojis.droplet: Emojis.bubbles, 
    },
    aoeRadius: 2, 
  );

  
  static final Reaction gale = Reaction(
    type: ReactionType.gale,
    triggers: [Emojis.tornado, Emojis.windFace],
    transformations: {
      Emojis.rock: Emojis.debris, 
      Emojis.derelictHouse: Emojis.debris, 
      Emojis.droplet: Emojis.cloud, 
      Emojis.fire: Emojis.fireworks, 
      Emojis.cloudWithLightning: Emojis.tornado,
    },
    aoeRadius: 2, 
  );

  static List<Reaction> get all => [electric, gale];
}