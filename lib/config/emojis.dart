class GameEmoji {
  final String hexCode;

  const GameEmoji(this.hexCode);

  String get svg => 'assets/emojis/svg/$hexCode.svg';
  String get lottie => 'assets/emojis/lottie/$hexCode.json';
}

class Emojis {
  static const GameEmoji cloud = GameEmoji('2601');
  static const GameEmoji fire  = GameEmoji('1f525');
  static const GameEmoji water = GameEmoji('1f4a7');
  static const GameEmoji plant = GameEmoji('1f331');
  static const GameEmoji rock  = GameEmoji('1faa8');
  static const GameEmoji wind  = GameEmoji('1f4a8'); 
}