import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';

class Chapter3Reactions {
  
  static final Reaction corrosive = Reaction(
    type: ReactionType.corrosive,
    triggers: [Emojis.biohazard], 
    transformations: {
      Emojis.chains: Emojis.brokenChain, 
      Emojis.locked: Emojis.openLock,    
      Emojis.shield: Emojis.metal,       
      Emojis.rock: Emojis.hole,          
    },
    aoeRadius: 1, 
  );

  
  static final Reaction seismic = Reaction(
    type: ReactionType.seismic,
    triggers: [Emojis.volcano], 
    transformations: {
      Emojis.rock: Emojis.debris,        
      Emojis.mountain: Emojis.debris,
      Emojis.skull: Emojis.bone,         
      Emojis.spider: Emojis.splatter,    
    },
    aoeRadius: 2, 
  );

  static List<Reaction> get all => [corrosive, seismic];
}