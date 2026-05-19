import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/chapters/chapter_1.dart';
import 'package:grimoji/config/levels/chapters/chapter_2.dart';
import 'package:grimoji/config/levels/chapters/chapter_3.dart';
import 'package:grimoji/config/levels/chapters/chapter_4.dart';
import 'package:grimoji/config/levels/chapters/chapter_5.dart';

final List<GameLevel> gameLevels = [
  ...chapter1Levels,
  ...chapter2Levels,
  ...chapter3Levels,
  ...chapter4Levels,
  ...chapter5Levels,
];