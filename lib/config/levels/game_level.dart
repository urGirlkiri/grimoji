import 'package:grimoji/config/emojis/index.dart';

class GameLevel {
  final int number;
  final int targetAmount;
  final int timeLimit;

  final GameEmoji targetEmoji;
  final List<GameEmoji> availableEmojis;

  final int crimsonStarTarget;
  final int extraTargetWeight;
  final int tileClearWeight;
  final int intrusiveWeight;
  final int shapeMergeWeight;
  final int ghostDiveWeight;
  final int blackHoleWeight;
  final int barberPoleWeight;

  final String? achievementIdIOS;
  final String? achievementIdAndroid;

  bool get awardsAchievement => achievementIdAndroid != null;

  const GameLevel({
    required this.number,
    required this.targetAmount,
    required this.timeLimit,
    required this.targetEmoji,
    required this.availableEmojis,

    this.crimsonStarTarget = 2500,
    this.extraTargetWeight = 30,
    this.tileClearWeight = 5,
    this.intrusiveWeight = 50,
    this.shapeMergeWeight = 20,
    this.ghostDiveWeight = 80,
    this.blackHoleWeight = 60,
    this.barberPoleWeight = 60,
    this.achievementIdIOS,
    this.achievementIdAndroid,
  }) : assert(
         (achievementIdAndroid != null && achievementIdIOS != null) ||
             (achievementIdAndroid == null && achievementIdIOS == null),
         'Either both iOS and Android achievement ID must be provided, '
         'or none',
       );
}
