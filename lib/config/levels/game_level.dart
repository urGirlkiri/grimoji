import 'package:grimoji/config/emojis.dart';

class GameLevel {
  final int number;
  final int targetAmount;
  final int timeLimit;
  
  final GameEmoji targetEmoji;
  final List<GameEmoji> availableEmojis;

  final String description;
  final String goal;

  final String? achievementIdIOS;
  final String? achievementIdAndroid;
  final bool skipAutoPlayer;

  bool get awardsAchievement => achievementIdAndroid != null;

  const GameLevel({
    required this.number,
    required this.targetAmount,
    required this.timeLimit,
    required this.targetEmoji,
    required this.availableEmojis,
    required this.goal,
    required this.description,
    this.skipAutoPlayer = false,
    this.achievementIdIOS,
    this.achievementIdAndroid,
  }) : assert(
         (achievementIdAndroid != null && achievementIdIOS != null) ||
             (achievementIdAndroid == null && achievementIdIOS == null),
         'Either both iOS and Android achievement ID must be provided, '
         'or none',
       );
}
