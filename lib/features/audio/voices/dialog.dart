enum Dialog {
  alchemy(text: 'Alchemy!', priority: 1),
  wickedAlchemy(text: 'Wicked Alchemy!', priority: 3),
  diabolicalAlchemy(text: 'Diabolical Alchemy!', priority: 3),
  sorcerousAlchemy(text: 'Sorcerous Alchemy!', priority: 4),
  magicalAlchemy(text: 'Magical Alchemy!!', priority: 5),
  masterfulAlchemy(text: 'Masterful Alchemy!!', priority: 5),

  alchemicalCalamity(text: 'Alchemical Calamity!', priority: 2),
  wickedCalamity(text: 'Wicked Calamity!', priority: 4),
  diabolicalCalamity(text: 'Diabolical Calamity!', priority: 4),
  sorcerousCalamity(text: 'Sorcerous Calamity!', priority: 4),
  magicalCalamity(text: 'Magical Calamity!!', priority: 5),

  catastrophicMasterpiece(text: 'A Catastrophic Masterpiece!!', priority: 6);

  final String text;
  final int priority;

  const Dialog({required this.text, required this.priority});
}
