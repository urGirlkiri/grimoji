import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';

final List<GameLevel> chapter2Levels = [
  GameLevel(
    number: 10,
    timeLimit: 200,
    targetAmount: 5,
    targetEmoji: Emojis.tRex,
    goal: 'Run across the bridge while being chased by a t-rex.',
    description: 'The Chase',
    availableEmojis: [
      Emojis.wheel,
      Emojis.victorySix,
      Emojis.wolf,
      Emojis.lizard,
    ],
  ),

  GameLevel(
    number: 11,
    timeLimit: 220,
    targetAmount: 3,
    targetEmoji: Emojis.spider,
    goal: 'Must merge 4 bugs to make Spiders',
    description: 'Arachnophobia - The swarm grows',
    availableEmojis: [
      Emojis.bug, 
      Emojis.scorpion, 
      Emojis.lobster, 
      Emojis.gasp
    ],
  ),

  GameLevel(
    number: 12,
    timeLimit: 240,
    targetAmount: 2,
    targetEmoji: Emojis.testTube,
    goal: 'Must merge 4 Droplets into Potions',
    description: 'First Brew - Distilling the swamp waters',
    availableEmojis: [
      Emojis.droplet,
      Emojis.ocean,
      Emojis.salt,
      Emojis.anxiousWithSweat,
    ],
  ),

  GameLevel(
    number: 13,
    timeLimit: 200,
    targetAmount: 4,
    targetEmoji: Emojis.herb,
    goal: 'Requires 5 LeafyGreens to brew',
    description: 'Toxic Overgrowth - The swamp fights back',
    availableEmojis: [
      Emojis.leafyGreen,
      Emojis.bug,
      Emojis.mushroom,
      Emojis.greenSalad,
    ],
  ),

  GameLevel(
    number: 14,
    timeLimit: 260,
    targetAmount: 2,
    targetEmoji: Emojis.bat,
    goal: 'Requires merging Bugs -> Spiders -> Bats',
    description: 'Creatures of the Night - The swarm evolves',
    availableEmojis: [Emojis.crab, Emojis.spider, Emojis.rock, Emojis.concerned],
  ),

  GameLevel(
    number: 15,
    timeLimit: 220,
    targetAmount: 5,
    targetEmoji: Emojis.heartEyesCat,
    goal: 'Introduce the Cat emoji for lore',
    description: 'The Witch\'s Familiar - A feline companion',
    availableEmojis: [
      Emojis.kissingCat,
      Emojis.crossedFingers,
      Emojis.beatingHeart,
      Emojis.skull,
    ],
  ),

  GameLevel(
    number: 16,
    timeLimit: 300,
    targetAmount: 6,
    targetEmoji: Emojis.testTube,
    goal: 'Must brew multiple potions while bugs interfere',
    description: 'Potion Master - Managing the chaos',
    availableEmojis: [Emojis.droplet, Emojis.bug, Emojis.rock, Emojis.fire],
  ),

  GameLevel(
    number: 17,
    timeLimit: 250,
    targetAmount: 10,
    targetEmoji: Emojis.bubbles,
    goal: 'Collect bubbling potions',
    description: 'Cauldron Bubble - The brew reaches a boil',
    availableEmojis: [
      Emojis.testTube,
      Emojis.clinkingGlasses,
      Emojis.dizzyFace,
      Emojis.clinkingBeerMugs,
    ],
  ),

  GameLevel(
    number: 18,
    timeLimit: 350,
    targetAmount: 1,
    targetEmoji: Emojis.redApple,
    goal: 'A rare item to collect amidst chaos',
    description: 'The Poisoned Apple - The final test of the swamp',
    availableEmojis: [
      Emojis.evergreenTree, 
      Emojis.flagInHole, 
      Emojis.frog, 
      Emojis.plant
    ],
  ),

  GameLevel(
    number: 19,
    timeLimit: 200,
    targetAmount: 3,
    targetEmoji: Emojis.snowflake,
    goal: 'Player must craft Snowflakes from Clouds',
    description: 'A Sudden Chill - Introducing Ice Magic',
    availableEmojis: [
      Emojis.cloud,
      Emojis.penguin,
      Emojis.iceSkate,
      Emojis.iceHockey,
    ],
  ),

  GameLevel(
    number: 20,
    timeLimit: 250,
    targetAmount: 8,
    targetEmoji: Emojis.melting,
    goal: 'Ice Cubes! Use freezing to stun replicating bugs',
    description: 'Pest Control - The swamp fights back with cold',
    availableEmojis: [
      Emojis.iceCream,
      Emojis.hotDog,
      Emojis.hotFace,
      Emojis.bomb,
    ],
  ),

  GameLevel(
    number: 21,
    timeLimit: 240,
    targetAmount: 5,
    targetEmoji: Emojis.spider,
    goal: 'Balance ice magic with biological threats',
    description: 'The Frozen Swamp - Cold traps the swarm',
    availableEmojis: [
      Emojis.bug,
      Emojis.broom,
      Emojis.frown,
      Emojis.skull,
    ],
  ),

  GameLevel(
    number: 22,
    timeLimit: 220,
    targetAmount: 12,
    targetEmoji: Emojis.fallenLeaf,
    goal: 'Created by freezing LeafyGreens',
    description: 'Decay - Nature withers in the frost',
    availableEmojis: [
      Emojis.leafyGreen,
      Emojis.evergreenTree,
      Emojis.tomato,
      Emojis.tulip,
    ],
  ),

  GameLevel(
    number: 23,
    timeLimit: 300,
    targetAmount: 4,
    targetEmoji: Emojis.testTube,
    goal: 'Keep bugs away from the potions',
    description: 'The Witch\'s Brew - Potions amid the storm',
    availableEmojis: [
      Emojis.droplet, 
      Emojis.herb, 
      Emojis.bug, 
      Emojis.fire
      ],
  ),

  GameLevel(
    number: 24,
    timeLimit: 260,
    targetAmount: 3,
    targetEmoji: Emojis.bat,
    goal: 'Combine Spiders to make Bats',
    description: 'Nightfall - The swarm evolves under cover of dark',
    availableEmojis: [
      Emojis.stethoscope, 
      Emojis.spider, 
      Emojis.cloud, 
      Emojis.ghost
    ],
  ),

  GameLevel(
    number: 25,
    timeLimit: 240,
    targetAmount: 5,
    targetEmoji: Emojis.snake,
    goal: 'A new toxic familiar to manage',
    description: 'Cold Blooded - The serpent moves in frozen shadows',
    availableEmojis: [
      Emojis.biohazard,
      Emojis.mask,
      Emojis.microbe,
    ],
  ),

  GameLevel(
    number: 26,
    timeLimit: 280,
    targetAmount: 3,
    targetEmoji: Emojis.rage,
    goal: 'First Emotion',
    description: 'Rage',
    availableEmojis: [
      Emojis.cursing, 
      Emojis.ogre, 
      Emojis.fuelPump, 
      Emojis.racingCar
    ],
  ),

  GameLevel(
    number: 27,
    timeLimit: 250,
    targetAmount: 15,
    targetEmoji: Emojis.bubbles,
    goal: 'Manage the bubbling brew',
    description: 'The Cauldron Bubbles - The final simmer',
    availableEmojis: [
      Emojis.testTube,
      Emojis.blood,
      Emojis.noEntry,
      Emojis.clinkingBeerMugs,
    ],
  ),

  GameLevel(
    number: 28,
    timeLimit: 400,
    targetAmount: 1,
    targetEmoji: Emojis.television,
    goal: 'Hard to craft amidst chaos',
    description: 'The Swamp Witch - The final trial of Chapter 2',
    availableEmojis: [
      Emojis.sparkles,
      Emojis.wand,
      Emojis.screamCat,
    ],
  ),
];
