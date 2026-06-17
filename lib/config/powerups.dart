import 'package:grimoji/config/emojis/index.dart';

class Powerup {
  final String id;
  final String name;
  final String iconPath;
  final String description;

  const Powerup({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.description,
  });

  static final List<Powerup> all = [
    Powerup(
      id: 'hourglass',
      name: 'Extra Time',
      iconPath: Emojis.hourglassNotDone.svg,
      description: 'Grants extra seconds to coordinate a massive combo.',
    ),
    Powerup(
      id: 'boxing_glove',
      name: 'The Glove',
      iconPath: Emojis.boxingGlove.svg,
      description:
          'Punches and destroys a single target without triggering surrounding tiles.',
    ),
    Powerup(
      id: 'test_tube',
      name: 'The Potion',
      iconPath: Emojis.testTube.svg,
      description: 'Transforms a target tile into a specific desired emoji.',
    ),
    Powerup(
      id: 'flying_disc',
      name: 'The UFO',
      iconPath: Emojis.flyingDisc.svg,
      description:
          'Beams down and mutates 3 random tiles into triggered bombs.',
    ),
    Powerup(
      id: 'crystal_ball',
      name: 'Insight',
      iconPath: Emojis.crystalBall.svg,
      description: 'Reveals a hidden path or optimal match.',
    ),

    Powerup(
      id: 'barber_pole',
      name: 'Line Clearer',
      iconPath: Emojis.barberPole.svg,
      description: 'Clears an entire row or column when swiped.',
    ),

    Powerup(
      id: 'wheel',
      name: 'Wheel',
      iconPath: Emojis.wheel.svg,
      description: 'Converts first 3 candies in its path into bombs.',
    ),

    Powerup(
      id: 'blood',
      name: 'Immortal Blood',
      iconPath: Emojis.blood.svg,
      description: 'Converts the emoji its dropped on into barbed poles.',
    ),

    Powerup(
      id: 'ghost',
      name: 'The Spirit',
      iconPath: Emojis.ghost.svg,
      description:
          'Flies off the board and dive-bombs the most crucial tile or obstacle.',
    ),

    Powerup(
      id: 'bomb',
      name: 'The Bomb',
      iconPath: Emojis.bomb.svg,
      description:
          'Detonates in a massive 3x3 radius, falls, and explodes a second time.',
    ),

    Powerup(
      id: 'hole',
      name: 'Black Hole',
      iconPath: Emojis.hole.svg,
      description:
          'Swallows all instances of the swapped emoji from the entire board.',
    ),

    Powerup(
      id: 'comet',
      name: 'Meteor',
      iconPath: Emojis.comet.svg,
      description: 'Crashes down to utterly destroy a targeted 3x3 area.',
    ),
  ];
}
