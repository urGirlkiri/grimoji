class ThreatScan {
  final List<List<String>> gridVisuals;
  final List<List<bool>> hasBehavior;
  final int rows;
  final int cols;
  final Set<String> intrusiveVisuals;
  final Set<String> unmatchableVisuals;
  final String targetVisual;
  final Set<String> targetIngredients;

  ThreatScan({
    required this.gridVisuals,
    required this.hasBehavior,
    required this.rows,
    required this.cols,
    required this.intrusiveVisuals,
    required this.unmatchableVisuals,
    required this.targetVisual,
    required this.targetIngredients,
  });
}
