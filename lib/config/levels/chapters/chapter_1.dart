import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/config/levels/game_level.dart';

const List<GameLevel> chapter1Levels = [
  GameLevel(
    number: 1,
    timeLimit: 120,
    targetAmount: 5,
    targetEmoji: Emojis.droplet,
    goal: 'Collect water',
    description: 'The Awakening - Super easy, introducing basic matches',
    availableEmojis: [
      Emojis.droplet,
      Emojis.leafyGreen,
      Emojis.fire,
      Emojis.rock,
    ],
    type: LevelType.puzzle,
  ),

  GameLevel(
    number: 2,
    timeLimit: 150,
    targetAmount: 3,
    targetEmoji: Emojis.mushroom,
    goal: 'The first alchemical yield!',
    description: 'Spark of Life - Focus on nature',
    availableEmojis: [
      Emojis.droplet,
      Emojis.leafyGreen,
      Emojis.fire,
      Emojis.rock,
    ],
    type: LevelType.puzzle,
  ),

  GameLevel(
    number: 3,
    timeLimit: 180,
    targetAmount: 10,
    targetEmoji: Emojis.skull,
    goal: 'Matches the graveyard theme',
    description: 'Unearthing the Dead - Introducing Skulls',
    availableEmojis: [
      Emojis.skull,
      Emojis.fire,
      Emojis.droplet,
      Emojis.rock,
      Emojis.spider,
    ],
    type: LevelType.puzzle,
  ),

  GameLevel(
    number: 4,
    timeLimit: 180,
    targetAmount: 3,
    targetEmoji: Emojis.bomb,
    goal: 'Players must craft bombs!',
    description: "The Alchemist's Fire",
    availableEmojis: [
      Emojis.fire,
      Emojis.leafyGreen,
      Emojis.rock,
      Emojis.skull,
      Emojis.spider,
    ],
    type: LevelType.puzzle,
  ),

  GameLevel(
    number: 5,
    timeLimit: 200,
    targetAmount: 5,
    targetEmoji: Emojis.bone,
    goal: 'Collect bones',
    description: 'Graveyard Shift',
    availableEmojis: [
      Emojis.skull,
      Emojis.bone,
      Emojis.rock,
      Emojis.fire,
      Emojis.droplet,
    ],
    type: LevelType.puzzle,
  ),

  GameLevel(
    number: 6,
    timeLimit: 200,
    targetAmount: 8,
    targetEmoji: Emojis.bug,
    goal: 'Collect bugs',
    description: 'Toxic Soils',
    availableEmojis: [
      Emojis.leafyGreen,
      Emojis.bug,
      Emojis.spider,
      Emojis.droplet,
      Emojis.rock,
    ],
    type: LevelType.puzzle,
  ),

  GameLevel(
    number: 7,
    timeLimit: 220,
    targetAmount: 15,
    targetEmoji: Emojis.fire,
    goal: 'Collect fire',
    description: 'Will-o\'-the-Wisp',
    availableEmojis: [
      Emojis.fire,
      Emojis.ghost,
      Emojis.skull,
      Emojis.droplet,
      Emojis.leafyGreen,
    ],
    type: LevelType.puzzle,
  ),

  GameLevel(
    number: 8,
    timeLimit: 240,
    targetAmount: 4,
    targetEmoji: Emojis.crystalBall,
    goal: 'Collect crystal balls',
    description: 'The Ritual Begins',
    availableEmojis: [
      Emojis.crystalBall,
      Emojis.fire,
      Emojis.rock,
      Emojis.droplet,
      Emojis.leafyGreen,
      Emojis.skull,
    ],
    type: LevelType.puzzle,
  ),

  GameLevel(
    number: 9,
    timeLimit: 300,
    targetAmount: 1,
    targetEmoji: Emojis.anatomicalHeart,
    goal: 'A complex recipe requirement!',
    description: 'Guardian of the Gate - Boss Level before the Cauldron',
    availableEmojis: [
      Emojis.bone,
      Emojis.skull,
      Emojis.fire,
      Emojis.droplet,
      Emojis.leafyGreen,
      Emojis.spider,
    ],
    type: LevelType.puzzle,
  ),
];