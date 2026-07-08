class IsoGroup {
  final String emoji;
  final bool isSpecial;
  final int size;
  final String? yieldEmoji;
  const IsoGroup(
    this.emoji, {
    this.isSpecial = false,
    this.size = 3,
    this.yieldEmoji,
  });
}
