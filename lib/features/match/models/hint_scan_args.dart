class HintScanArgs {
  final List<List<String>> gridVisuals;
  final List<List<bool>> hasBehavior;
  final int rows;
  final int cols;
  final String targetVisual;
  final Map<String, int> recipeChainSteps;
  final Set<String> unmatchableVisuals;

  HintScanArgs({
    required this.gridVisuals,
    required this.hasBehavior,
    required this.rows,
    required this.cols,
    required this.targetVisual,
    required this.recipeChainSteps,
    required this.unmatchableVisuals,
  });
}
