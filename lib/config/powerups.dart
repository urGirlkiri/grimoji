import 'package:grimoji/config/emojis/index.dart';

class Powerup {
  final String id;
  final String name;
  final String iconPath;
  final String description;
  final bool isPrelevel;

  const Powerup({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.description,
    this.isPrelevel = false
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
      id: 'ufo',
      name: 'The UFO',
      iconPath: Emojis.flyingSaucer.svg,
      description:
          'Beams down and mutates 3 random tiles into triggered bombs.',
    ),
    Powerup(
      id: 'crystal_ball',
      name: 'Insight',
      iconPath: Emojis.crystalBall.svg,
      description: 'Reveals a hidden path or optimal match.',
      isPrelevel: true
    ),

    Powerup(
      id: 'barber_pole',
      name: 'Line Clearer',
      iconPath: Emojis.barberPole.svg,
      description: 'Clears an entire row or column when swiped.',
      isPrelevel: true

    ),

    Powerup(
      id: 'wheel',
      name: 'Wheel',
      iconPath: Emojis.wheel.svg,
      description: 'Converts first 3 candies in its path into bombs.',
      isPrelevel: true

    ),

    Powerup(
      id: 'blood',
      name: 'Immortal Blood',
      iconPath: Emojis.blood.svg,
      description: 'Converts the emoji its dropped on into barbed poles.',
    ),

    const Powerup(
      id: 'board_sweep',
      name: 'Board Sweep Combo',
      iconPath: 'assets/images/map/board_sweep.svg',
      description:
          'Spawns Bombo and Sweep when level starts',
      isPrelevel: true

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
