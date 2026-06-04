import 'package:grimoji/features/audio/voices/dialog.dart';

class Voice {
  final String file;
  final String actor;

  const Voice({
    required this.file,
    required this.actor,
  });
}

class Voices {
  static const Map<Dialog, List<Voice>> voices = {
    Dialog.alchemy: [
      Voice(file: 'alchemy.mp3', actor: 'elevenlabs'),
      Voice(file: 'alchemy_2.mp3', actor: 'elevenlabs'),
    ],
    Dialog.wickedAlchemy: [
      Voice(file: 'wicked_alchemy.mp3', actor: 'elevenlabs'),
      Voice(file: 'wicked_alchemy_2.mp3', actor: 'elevenlabs'),
    ],
    Dialog.diabolicalAlchemy: [
      Voice(file: 'diabolical_alchemy.mp3', actor: 'elevenlabs'),
      Voice(file: 'diabolical_alchemy_2.mp3', actor: 'elevenlabs'),
    ],
    Dialog.sorcerousAlchemy: [
      Voice(file: 'sorcerous_alchemy.mp3', actor: 'elevenlabs'),
      Voice(file: 'sorcerous_alchemy_2.mp3', actor: 'elevenlabs'),
    ],
    Dialog.magicalAlchemy: [
      Voice(file: 'magical_alchemy.mp3', actor: 'elevenlabs'),
      Voice(file: 'magical_alchemy_2.mp3', actor: 'elevenlabs'),
    ],
    Dialog.masterfulAlchemy: [
      Voice(file: 'masterful_alchemy.mp3', actor: 'elevenlabs'),
      Voice(file: 'masterful_alchemy_2.mp3', actor: 'elevenlabs'),
    ],
    Dialog.alchemicalCalamity: [
      Voice(file: 'alchemical_calamity.mp3', actor: 'elevenlabs'),
      Voice(file: 'alchemical_calamity_2.mp3', actor: 'elevenlabs'),
    ],
    Dialog.wickedCalamity: [
      Voice(file: 'wicked_calamity.mp3', actor: 'elevenlabs'),
      Voice(file: 'wicked_calamity_2.mp3', actor: 'elevenlabs'),
    ],
    Dialog.diabolicalCalamity: [
      Voice(file: 'diabolical_calamity.mp3', actor: 'elevenlabs'),
      Voice(file: 'diabolical_calamity_2.mp3', actor: 'elevenlabs'),
    ],
    Dialog.sorcerousCalamity: [
      Voice(file: 'sorcerous_calamity.mp3', actor: 'elevenlabs'),
      Voice(file: 'sorcerous_calamity_2.mp3', actor: 'elevenlabs'),
    ],
    Dialog.magicalCalamity: [
      Voice(file: 'magical_calamity.mp3', actor: 'elevenlabs'),
      Voice(file: 'magical_calamity_2.mp3', actor: 'elevenlabs'),
    ],
    Dialog.catastrophicMasterpiece: [
      Voice(file: 'a_catastrophic_masterpiece.mp3', actor: 'elevenlabs'),
      Voice(file: 'a_catastrophic_masterpiece_2.mp3', actor: 'elevenlabs'),
    ],
  };

  static Voice? getVoice(Dialog type) {
    final list = voices[type];
    if (list == null || list.isEmpty) return null;
    return list[DateTime.now().millisecondsSinceEpoch % list.length];
  }
}