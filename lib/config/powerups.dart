import 'package:grimoji/config/emojis/index.dart';

class Powerup {
  final String id;
  final String name;
  final String iconPath;
  final String description;
  final bool isPrelevel;
  final int price;
  final int bundleAmount;

  const Powerup({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.description,
    required this.price,
    this.isPrelevel = false,
    this.bundleAmount = 3,
  });

  static final List<Powerup> all = [
    const Powerup(
      id: 'board_sweep',
      name: 'Board Sweep Combo',
      iconPath: 'assets/images/map/board_sweep.svg',
      description: 'Spawns Bombo and Sweep when level starts.',
      isPrelevel: true,
      price: 50,
    ),
    Powerup(
      id: 'hole',
      name: 'Black Hole',
      iconPath: Emojis.hole.svg,
      description:
          'Swallows all instances of the swapped emoji from the entire board.',
      isPrelevel: true,
      price: 40,
    ),
    Powerup(
      id: 'ghost',
      name: 'Haunting Ghost',
      iconPath: Emojis.ghost.svg,
      description: 'Dives into an emoji and destroys it.',
      isPrelevel: true,
      price: 25,
    ),
    Powerup(
      id: 'wheel',
      name: 'Wheel',
      iconPath: Emojis.wheel.svg,
      description: 'Converts first 3 emojis in its path into bombs.',
      isPrelevel: true,
      price: 35,
    ),

    Powerup(
      id: 'crystal_ball',
      name: 'Hints',
      iconPath: Emojis.crystalBall.svg,
      description: 'Gives you helpful hints during play.',
      isPrelevel: true,
      price: 20,
    ),
    Powerup(
      id: 'hourglass',
      name: 'Extra Time',
      iconPath: Emojis.hourglassNotDone.svg,
      description: 'Grants extra seconds to coordinate a massive combo.',
      price: 30,
    ),
    Powerup(
      id: 'boxing_glove',
      name: 'The Glove',
      iconPath: Emojis.boxingGlove.svg,
      description:
          'Punches and destroys a single target without triggering surrounding tiles.',
      price: 25,
    ),
    Powerup(
      id: 'test_tube',
      name: 'The Potion',
      iconPath: Emojis.testTube.svg,
      description: 'Drop it on a tile to complete a match.',
      price: 35,
    ),
    Powerup(
      id: 'ufo',
      name: 'The UFO',
      iconPath: Emojis.flyingSaucer.svg,
      description:
          'Beams down and mutates 3 random tiles into triggered bombs.',
      price: 45,
    ),
    Powerup(
      id: 'blood',
      name: 'Immortal Blood',
      iconPath: Emojis.blood.svg,
      description: 'Converts the emoji its dropped on into crossing clear.',
      price: 30,
    ),
    Powerup(
      id: 'comet',
      name: 'Meteor',
      iconPath: Emojis.comet.svg,
      description: 'Crashes down to destroy a targeted area.',
      price: 55,
    ),
  ];

  static List<Powerup> get prelevel => all.where((p) => p.isPrelevel).toList();

  static List<Powerup> get bottom => all.where((p) => !p.isPrelevel).toList();

  static Powerup? byId(String id) =>
      all.cast<Powerup?>().firstWhere((p) => p!.id == id, orElse: () => null);

  String? get lottiePath {
    if (id == 'wheel' || id == 'boxing_glove') return null;
    return emojiForId(id)?.lottie;
  }

  static GameEmoji? emojiForId(String id) {
    final powerup = byId(id);
    if (powerup == null) return null;
    final svgPath = powerup.iconPath;
    return Emojis.all.cast<GameEmoji?>().firstWhere(
      (e) => e!.svg == svgPath,
      orElse: () => null,
    );
  }
}
