enum Dialog {
  alchemy(text: 'Alchemy!', priority: 1, minCombo: 1, isCalamity: false),
  wickedAlchemy(text: 'Wicked Alchemy!', priority: 3, minCombo: 2, isCalamity: false),
  diabolicalAlchemy(text: 'Diabolical Alchemy!', priority: 3, minCombo: 3, isCalamity: false),
  sorcerousAlchemy(text: 'Sorcerous Alchemy!', priority: 4, minCombo: 4, isCalamity: false),
  magicalAlchemy(text: 'Magical Alchemy!!', priority: 5, minCombo: 5, isCalamity: false),
  masterfulAlchemy(text: 'Masterful Alchemy!!', priority: 5, minCombo: 6, isCalamity: false),
  alchemicalCalamity(text: 'Alchemical Calamity!', priority: 2, minCombo: 1, isCalamity: true),
  wickedCalamity(text: 'Wicked Calamity!', priority: 4, minCombo: 2, isCalamity: true),
  diabolicalCalamity(text: 'Diabolical Calamity!', priority: 4, minCombo: 3, isCalamity: true),
  sorcerousCalamity(text: 'Sorcerous Calamity!', priority: 4, minCombo: 4, isCalamity: true),
  magicalCalamity(text: 'Magical Calamity!!', priority: 5, minCombo: 5, isCalamity: true),
  catastrophicMasterpiece(text: 'A Catastrophic Masterpiece!!', priority: 6, minCombo: 6, isCalamity: true);

  final String text;
  final int priority;
  final int minCombo;
  final bool isCalamity;

  const Dialog({
    required this.text,
    required this.priority,
    required this.minCombo,
    required this.isCalamity,
  });
}