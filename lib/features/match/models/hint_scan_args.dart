class HintScanArgs {
  final List<List<String>> gridVisuals;
  final List<List<bool>> hasBehavior;
  final int rows;
  final int cols;
  final String targetVisual;
  final Set<String> targetIngredients;
  final Set<String> unmatchableVisuals;

  HintScanArgs({
    required this.gridVisuals,
    required this.hasBehavior,
    required this.rows,
    required this.cols,
    required this.targetVisual,
    required this.targetIngredients,
    required this.unmatchableVisuals,
  });
}
