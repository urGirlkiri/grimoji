import 'package:grimoji/features/match/board/effect/manager.dart';

class LineClearEffect extends BoardEffect {
  final int row;
  final int col;
  final bool isHorizontal;

  LineClearEffect({
    required this.row,
    required this.col,
    required this.isHorizontal,
  }) : super();
}
