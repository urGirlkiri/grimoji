import 'package:grimoji/config/emojis.dart';

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
      id: 'crystal_ball',
      name: 'Insight',
      iconPath: Emojis.crystalBall.svg,
      description: 'Reveals a hidden path.',
    ),
    Powerup(
      id: 'test_tube',
      name: 'Alchemy',
      iconPath: Emojis.testTube.svg,
      description: 'Transmutes basic elements.',
    ),
    Powerup(
      id: 'flying_disc',
      name: 'Abduct',
      iconPath: Emojis.flyingDisc.svg,
      description: 'Removes an obstacle.',
    ),
    Powerup(
      id: 'comet',
      name: 'Meteor',
      iconPath: Emojis.comet.svg,
      description: 'Destroys a 3x3 area.',
    ),
  ];
}
