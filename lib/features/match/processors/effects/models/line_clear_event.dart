class LineClearEvent {
  final int row;
  final int col;
  final bool isHorizontal;

  LineClearEvent({
    required this.row,
    required this.col,
    required this.isHorizontal,
  });
}
