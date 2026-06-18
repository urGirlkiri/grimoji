import 'package:grimoji/features/audio/voices/dialog.dart';

class Voice {
  final String file;
  final String actor;

  const Voice({required this.file, required this.actor});
}

class Voices {
  static const Map<Dialog, List<Voice>> voices = {
    Dialog.alchemy: [
      Voice(file: 'alchemy.m4a', actor: 'elevenlabs'),
      Voice(file: 'alchemy_2.m4a', actor: 'elevenlabs'),
    ],
    Dialog.wickedAlchemy: [
      Voice(file: 'wicked_alchemy.m4a', actor: 'elevenlabs'),
      Voice(file: 'wicked_alchemy_2.m4a', actor: 'elevenlabs'),
    ],
    Dialog.diabolicalAlchemy: [
      Voice(file: 'diabolical_alchemy.m4a', actor: 'elevenlabs'),
      Voice(file: 'diabolical_alchemy_2.m4a', actor: 'elevenlabs'),
    ],
    Dialog.sorcerousAlchemy: [
      Voice(file: 'sorcerous_alchemy.m4a', actor: 'elevenlabs'),
      Voice(file: 'sorcerous_alchemy_2.m4a', actor: 'elevenlabs'),
    ],
    Dialog.magicalAlchemy: [
      Voice(file: 'magical_alchemy.m4a', actor: 'elevenlabs'),
      Voice(file: 'magical_alchemy_2.m4a', actor: 'elevenlabs'),
    ],
    Dialog.masterfulAlchemy: [
      Voice(file: 'masterful_alchemy.m4a', actor: 'elevenlabs'),
      Voice(file: 'masterful_alchemy_2.m4a', actor: 'elevenlabs'),
    ],
    Dialog.alchemicalCalamity: [
      Voice(file: 'alchemical_calamity.m4a', actor: 'elevenlabs'),
      Voice(file: 'alchemical_calamity_2.m4a', actor: 'elevenlabs'),
    ],
    Dialog.wickedCalamity: [
      Voice(file: 'wicked_calamity.m4a', actor: 'elevenlabs'),
      Voice(file: 'wicked_calamity_2.m4a', actor: 'elevenlabs'),
    ],
    Dialog.diabolicalCalamity: [
      Voice(file: 'diabolical_calamity.m4a', actor: 'elevenlabs'),
      Voice(file: 'diabolical_calamity_2.m4a', actor: 'elevenlabs'),
    ],
    Dialog.sorcerousCalamity: [
      Voice(file: 'sorcerous_calamity.m4a', actor: 'elevenlabs'),
      Voice(file: 'sorcerous_calamity_2.m4a', actor: 'elevenlabs'),
    ],
    Dialog.magicalCalamity: [
      Voice(file: 'magical_calamity.m4a', actor: 'elevenlabs'),
      Voice(file: 'magical_calamity_2.m4a', actor: 'elevenlabs'),
    ],
    Dialog.catastrophicMasterpiece: [
      Voice(file: 'a_catastrophic_masterpiece.m4a', actor: 'elevenlabs'),
      Voice(file: 'a_catastrophic_masterpiece_2.m4a', actor: 'elevenlabs'),
    ],
  };

  static Voice? getVoice(Dialog type) {
    final list = voices[type];
    if (list == null || list.isEmpty) return null;
    return list[DateTime.now().millisecondsSinceEpoch % list.length];
  }
}
