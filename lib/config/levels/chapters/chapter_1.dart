import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';

final List<GameLevel> chapter1Levels = [
  GameLevel(
    number: 1,
    timeLimit: 120,
    targetAmount: 5,
    targetEmoji: Emojis.ocean,
    availableEmojis: [
      Emojis.droplet, 
      Emojis.fire, 
      Emojis.rock, 
    ],
  ),

  GameLevel(
    number: 2,
    timeLimit: 150,
    targetAmount: 3,
    targetEmoji: Emojis.mushroom,
    availableEmojis: [
      Emojis.leafyGreen,
      Emojis.avocado,
      // Emojis.grin,
      Emojis.beans,
    ],
  ),

  GameLevel(
    number: 3,
    timeLimit: 180,
    targetAmount: 10,
    targetEmoji: Emojis.skull,
    availableEmojis: [
      Emojis.bone,
      Emojis.rock,
      Emojis.bat
    ],
  ),

  GameLevel(
    number: 4,
    timeLimit: 180,
    targetAmount: 3,
    targetEmoji: Emojis.bomb,
    availableEmojis: [
      Emojis.fire,
      Emojis.leaflessTree,
      Emojis.fireworks,
      Emojis.mapleLeaf,
    ],
  ),

  GameLevel(
    number: 5,
    timeLimit: 200,
    targetAmount: 5,
    targetEmoji: Emojis.bone,
    availableEmojis: [
      Emojis.skull,
      Emojis.rock,
      Emojis.ghost,
      Emojis.poultryLeg,
    ],
  ),

  GameLevel(
    number: 6,
    timeLimit: 200,
    targetAmount: 8,
    targetEmoji: Emojis.bug,
    availableEmojis: [
      Emojis.worm,
      Emojis.wiltedFlower,
      Emojis.scared,
      Emojis.rooster,
    ],
  ),

  GameLevel(
    number: 7,
    timeLimit: 220,
    targetAmount: 15,
    targetEmoji: Emojis.fire,
    availableEmojis: [
      Emojis.leaflessTree,
      Emojis.windFace,
      Emojis.hotFace,
    ],
  ),

  GameLevel(
    number: 8,
    timeLimit: 240,
    targetAmount: 4,
    targetEmoji: Emojis.crystalBall,
    availableEmojis: [
      Emojis.graduationCap,
      Emojis.sparkles,
      Emojis.writingHand,
      Emojis.yawn
    ],
  ),

  GameLevel(
    number: 9,
    timeLimit: 300,
    targetAmount: 10,
    targetEmoji: Emojis.anatomicalHeart,
    availableEmojis: [
      Emojis.bandagedHeart,
      Emojis.bandageFace,
      Emojis.dottedLineFace,
      Emojis.hearNoEvilMonkey,
    ],
  ),
];
