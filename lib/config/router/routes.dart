class Destination {
  const Destination({required this.label, required this.imagePath});

  final String label;
  final String imagePath;
}

const destinations = [
  Destination(label: 'Map',      imagePath: 'assets/images/tab/map.png'),
  Destination(label: 'Grimoire', imagePath: 'assets/images/tab/grimoire.png'), 
  Destination(label: 'Cauldron', imagePath: 'assets/images/tab/cauldron.png'), 
  Destination(label: 'Coven',    imagePath: 'assets/images/tab/coven.png'), 
  Destination(label: 'Market',   imagePath: 'assets/images/tab/market.png'),
];

class Routes {
  static const String homeRoute = '/';

  static const String mapRoute      = '/map';
  static const String grimoireRoute = '/grimoire'; 
  static const String cauldronRoute = '/cauldron';
  static const String covenRoute    = '/coven';    
  static const String marketRoute   = '/market';

  static const String levelHintRoute = '/map/hint/:level';
  static const String levelPlayRoute = '/map/play/:level';
  static const String levelWonRoute  = '/map/won';
  static const String levelFailRoute = '/map/lose/:level';

  static const String bountiesRoute  = '/market/bounties'; 
  static const String settingsRoute  = '/settings';


  static const String home = 'home';

  static const String map      = 'map';
  static const String grimoire = 'grimoire';
  static const String cauldron = 'cauldron';
  static const String coven    = 'coven';
  static const String market   = 'market';

  static const String levelHint = 'levelHint';
  static const String levelPlay = 'levelPlay';
  static const String levelWon  = 'levelWon';
  static const String levelFail = 'levelFail';

  static const String bounties = 'bounties';
  static const String settings = 'settings';
}