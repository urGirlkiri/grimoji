import 'package:uuid/uuid.dart';

class LineClearEffect {
  final String id;
  final int row;
  final int col;
  final bool isHorizontal;

  LineClearEffect({
    required this.row,
    required this.col,
    required this.isHorizontal,
    String? id,
  }) : id = id ?? const Uuid().v4();
}
