import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';

const List<GameLevel> chapter4Levels = [
  GameLevel(
    number: 49,
    timeLimit: 240,
    targetAmount: 4,
    targetEmoji: Emojis.cloudWithLightning,
    goal: 'Craft storm clouds from wind currents',
    description: 'High Altitudes - The sky calls',
    availableEmojis: [
      Emojis.windFace,
      Emojis.cloud,
      Emojis.droplet,
      Emojis.rock,
    ],
  ),

  GameLevel(
    number: 50,
    timeLimit: 260,
    targetAmount: 15,
    targetEmoji: Emojis.blackBird,
    goal: 'Collect a murder of crows',
    description: 'A Murder of Crows - The flock grows',
    availableEmojis: [
      Emojis.blackBird,
      Emojis.windFace,
      Emojis.cloud,
      Emojis.leafyGreen,
    ],
  ),

  GameLevel(
    number: 51,
    timeLimit: 220,
    targetAmount: 6,
    targetEmoji: Emojis.poultryLeg,
    goal: 'Use lightning to fry the birds!',
    description: 'Lightning Strikes - Conductivity test',
    availableEmojis: [
      Emojis.blackBird,
      Emojis.cloudWithLightning,
      Emojis.windFace,
      Emojis.droplet,
    ],
  ),

  GameLevel(
    number: 52,
    timeLimit: 280,
    targetAmount: 3,
    targetEmoji: Emojis.eagle,
    goal: 'Combine 4 crows to form a giant eagle',
    description: 'The Apex Predator - King of the skies',
    availableEmojis: [
      Emojis.blackBird,
      Emojis.windFace,
      Emojis.rock,
      Emojis.bone,
    ],
  ),

  GameLevel(
    number: 53,
    timeLimit: 300,
    targetAmount: 2,
    targetEmoji: Emojis.tornado,
    goal: 'Craft tornadoes to destroy the derelict house',
    description: 'Category 5 - The storm arrives',
    availableEmojis: [
      Emojis.cloudWithLightning,
      Emojis.windFace,
      Emojis.derelictHouse,
      Emojis.droplet,
    ],
  ),

  GameLevel(
    number: 54,
    timeLimit: 260,
    targetAmount: 10,
    targetEmoji: Emojis.cloud,
    goal: 'Use tornadoes on droplets to spawn clouds',
    description: 'Updraft - The cycle continues',
    availableEmojis: [
      Emojis.tornado,
      Emojis.droplet,
      Emojis.rock,
      Emojis.blackBird,
    ],
  ),

  GameLevel(
    number: 55,
    timeLimit: 280,
    targetAmount: 5,
    targetEmoji: Emojis.electricity,
    goal: 'Harness the power of pure electricity',
    description: 'The Thunderbolt - The storm\'s heart',
    availableEmojis: [
      Emojis.cloudWithLightning,
      Emojis.eagle,
      Emojis.windFace,
      Emojis.fire,
    ],
    skipAutoPlayer: true,
  ),
  
  GameLevel(
    number: 56,
    timeLimit: 260,
    targetAmount: 8,
    targetEmoji: Emojis.cloud,
    goal: 'Clear the skies of invasive bugs',
    description: 'Turbulence - The wind stirs',
    availableEmojis: [
      Emojis.windFace,
      Emojis.droplet,
      Emojis.rock,
      Emojis.bug,
    ],
  ),

  
  GameLevel(
    number: 57,
    timeLimit: 280,
    targetAmount: 5,
    targetEmoji: Emojis.collision,
    goal: 'Short circuit the robots with lightning',
    description: 'The Lightning Rod - Conductivity test',
    availableEmojis: [
      Emojis.robot,
      Emojis.cloudWithLightning,
      Emojis.windFace,
      Emojis.chains,
    ],
  ),

  
  GameLevel(
    number: 58,
    timeLimit: 300,
    targetAmount: 3,
    targetEmoji: Emojis.tornado,
    goal: 'Survive the eye of the storm',
    description: 'Eye of the Storm - The calm within',
    availableEmojis: [
      Emojis.cloud,
      Emojis.windFace,
      Emojis.rock,
      Emojis.mountain,
    ],
    skipAutoPlayer: true,
  ),

  
  GameLevel(
    number: 59,
    timeLimit: 250,
    targetAmount: 10,
    targetEmoji: Emojis.electricity,
    goal: 'Harness the power of static electricity',
    description: 'Static Charge - The storm\'s heart',
    availableEmojis: [
      Emojis.cloudWithLightning,
      Emojis.fire,
      Emojis.droplet,
      Emojis.robot,
    ],
    skipAutoPlayer: true,
  ),

  
  GameLevel(
    number: 60,
    timeLimit: 300,
    targetAmount: 4,
    targetEmoji: Emojis.snowflake,
    goal: 'Bring back ice magic with freezing winds',
    description: 'Freezing Winds - The cold arrives',
    availableEmojis: [
      Emojis.cloud,
      Emojis.windFace,
      Emojis.droplet,
      Emojis.spider,
    ],
  ),

  
  GameLevel(
    number: 61,
    timeLimit: 280,
    targetAmount: 4,
    targetEmoji: Emojis.eagle,
    goal: 'Build an aviary for the eagles',
    description: 'The Aviary - Wings of the sky',
    availableEmojis: [
      Emojis.blackBird,
      Emojis.windFace,
      Emojis.leafyGreen,
      Emojis.bone,
    ],
  ),

  
  GameLevel(
    number: 62,
    timeLimit: 240,
    targetAmount: 15,
    targetEmoji: Emojis.poultryLeg,
    goal: 'Use lightning to cook the chickens',
    description: 'Fried Chicken - The feast begins',
    availableEmojis: [
      Emojis.blackBird,
      Emojis.eagle,
      Emojis.cloudWithLightning,
      Emojis.fire,
    ],
  ),

  
  GameLevel(
    number: 63,
    timeLimit: 320,
    targetAmount: 5,
    targetEmoji: Emojis.tornado,
    goal: 'Destroy the derelict house with hurricanes',
    description: 'Hurricane - The storm\'s fury',
    availableEmojis: [
      Emojis.cloudWithLightning,
      Emojis.windFace,
      Emojis.derelictHouse,
      Emojis.rock,
    ],
  ),

  
  GameLevel(
    number: 64,
    timeLimit: 300,
    targetAmount: 8,
    targetEmoji: Emojis.biohazard,
    goal: 'Create acid rain to unlock the facility',
    description: 'Acid Rain II - The chemical storm',
    availableEmojis: [
      Emojis.snake,
      Emojis.cloud,
      Emojis.droplet,
      Emojis.locked,
    ],
  ),

  
  GameLevel(
    number: 65,
    timeLimit: 280,
    targetAmount: 12,
    targetEmoji: Emojis.collision,
    goal: 'Overload the mechanical systems',
    description: 'Mechanical Failure - The robots rebel',
    availableEmojis: [
      Emojis.robot,
      Emojis.cloudWithLightning,
      Emojis.chains,
      Emojis.metal,
    ],
  ),

  
  GameLevel(
    number: 66,
    timeLimit: 260,
    targetAmount: 15,
    targetEmoji: Emojis.debris,
    goal: 'Scatter dust across the mountains',
    description: 'Scattering Dust - The airborne plague',
    availableEmojis: [
      Emojis.rock,
      Emojis.tornado,
      Emojis.mountain,
      Emojis.windFace,
    ],
  ),

  
  GameLevel(
    number: 67,
    timeLimit: 300,
    targetAmount: 6,
    targetEmoji: Emojis.eagle,
    goal: 'Build the ultimate eagle nest',
    description: 'The Nest - A home in the sky',
    availableEmojis: [
      Emojis.blackBird,
      Emojis.windFace,
      Emojis.rock,
      Emojis.cloud,
    ],
  ),

  
  GameLevel(
    number: 68,
    timeLimit: 450,
    targetAmount: 1,
    targetEmoji: Emojis.phoenix,
    goal: 'Combine 5 eagles to form a phoenix',
    description: 'Rebirth in the Sky - The final storm',
    availableEmojis: [
      Emojis.eagle,
      Emojis.fire,
      Emojis.cloudWithLightning,
      Emojis.tornado,
      Emojis.rock,
    ],
    skipAutoPlayer: true
  ),
];